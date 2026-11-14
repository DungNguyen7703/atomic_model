/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_dynamic_report_explorer_indicator
* Program name: Dtm Operational Dynamic Report Explorer Indicator (metadata chỉ tiêu Data Explorer QLQ)
* Created by: claude (sync)
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		claude (sync)		Tạo mới theo LLD DTM_QLQ_opr_dynamic_report_explorer_indicator_*.csv — port Spark SQL từ
*                                       Datamart/flat-table/QLQ/02_populate_qlq_flat_tables.sql khối 22 (bản ClickHouse).
*                                       Chỉ tiêu = mọi ô của mẫu báo cáo (gồm cả chỉ tiêu chưa có dữ liệu), 1 dòng/indicator_id.
*                                       PHẢI chạy SAU dtm_opr_dynamic_report_explorer_val (suy unit_nm số/chữ) — đã ref().
*                                       Nạp TOÀN BỘ mỗi lần chạy (O_QLQ_80) — incremental_rebase append không partition_by.
*--------------------------------------------------------------------*
*/

WITH dr_value AS (
    SELECT
        dr_structure_code,
        dr_submission_history_code,
        dynamic_ind,
        label_column_ind,
        data_tp
    FROM {{ ref('atm_dr_value') }}
    WHERE src_stm_code = 'FMS_ITEM_VALUE'
        AND submission_dt IS NOT NULL
),

structure_dim AS (
    SELECT
        dr_structure_code,
        rpt_code,
        rpt_nm,
        sheet_nm,
        column_path,
        structure_row_path,
        legal_basis,
        column_index,
        row_index,
        regexp_replace(coalesce(structure_row_path, ''), '^\\s+|\\s+$', '')    AS srp_t,
        regexp_replace(coalesce(legal_basis, ''), '^\\s+|\\s+$', '')           AS lb_t
    FROM {{ ref('dtm_dynamic_report_structure_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

submission_hist AS (
    SELECT
        dr_submission_history_code,
        submission_rpt_code,
        object_id,
        object_tp,
        object_sub_tp,
        period_tp,
        period_val,
        rpt_version
    FROM {{ ref('dtm_dynamic_report_submission_history_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

-- Lần nộp thắng (cùng quy tắc với dtm_opr_dynamic_report_explorer_val)
submission_win AS (
    SELECT dr_submission_history_code AS log_id
    FROM (
        SELECT
            dr_submission_history_code,
            coalesce(CAST(rpt_version AS bigint), -9223372036854775807) AS ver,
            max(coalesce(CAST(rpt_version AS bigint), -9223372036854775807)) OVER (
                PARTITION BY coalesce(object_id, ''), coalesce(submission_rpt_code, ''),
                             coalesce(period_tp, ''), coalesce(period_val, '')
            ) AS best_ver
        FROM submission_hist
    ) v
    WHERE v.ver = v.best_ver
),

-- Ưu tiên 1: chỉ tiêu CÓ dữ liệu (thuộc tính lấy từ ô giá trị của lần nộp thắng)
p1_cell AS (
    SELECT
        c.*,
        md5(concat(c.rkey, '|', c.skey, '|', CASE WHEN c.isd THEN concat(c.erp, ' > ...') ELSE c.erp END, '|', c.ckey)) AS id
    FROM (
        SELECT
            s.dr_structure_code                                                     AS ik,
            coalesce(f.dynamic_ind, 0) = 1                                          AS isd,
            CASE WHEN coalesce(f.dynamic_ind, 0) = 1 THEN
                     CASE WHEN s.srp_t = '...' THEN ''
                          ELSE regexp_replace(regexp_replace(substring_index(s.srp_t, ' > ...', 1), '[ >]+$', ''),
                                              '^\\s+|\\s+$', '') END
                 ELSE coalesce(s.structure_row_path, '') END                        AS erp,
            CASE WHEN s.lb_t <> '' THEN concat(coalesce(s.rpt_code, ''), '|', s.lb_t)
                 ELSE coalesce(s.rpt_code, '') END                                  AS rkey,
            coalesce(s.sheet_nm, 'None')                                            AS skey,
            coalesce(s.column_path, 'None')                                         AS ckey,
            coalesce(s.rpt_code, '')                                                AS rcode,
            coalesce(s.rpt_nm, '')                                                  AS rn,
            coalesce(s.sheet_nm, '')                                                AS sn,
            coalesce(s.column_path, '')                                             AS cp,
            CAST(coalesce(s.column_index, 0) AS bigint)                             AS colidx,
            CAST(s.row_index AS bigint)                                             AS rowidx,
            CASE WHEN lower(regexp_replace(coalesce(f.data_tp, ''), '^\\s+|\\s+$', ''))
                          NOT IN ('numberic', 'number', 'numeric', 'percentage')
                      OR coalesce(f.label_column_ind, 0) = 1
                 THEN 1 ELSE 0 END                                                  AS nonnum
        FROM dr_value f
        INNER JOIN structure_dim s
            ON s.dr_structure_code = f.dr_structure_code
        INNER JOIN submission_win w
            ON w.log_id = f.dr_submission_history_code
    ) c
),

p1 AS (
    SELECT
        id,
        min_by(erp, ik)                                                             AS erp,
        min_by(CASE WHEN isd THEN 1 ELSE 0 END, ik)                                 AS isd,
        min_by(rcode, ik)                                                           AS rcode,
        min_by(rn, ik)                                                              AS rn,
        min_by(sn, ik)                                                              AS sn,
        min_by(cp, ik)                                                              AS cp,
        min_by(colidx, ik)                                                          AS colidx,
        min_by(rowidx, ik)                                                          AS rowidx,
        CASE WHEN max(nonnum) = 0 THEN 1 ELSE 0 END                                 AS declared,
        1                                                                           AS prio,
        min(ik)                                                                     AS ikm
    FROM p1_cell
    GROUP BY id
    HAVING min_by(rn, ik) <> '' OR min_by(sn, ik) <> ''
),

-- Ưu tiên 2: chỉ tiêu TĨNH của mẫu chưa có dữ liệu (đường dẫn hàng không chứa ' > ...')
p2 AS (
    SELECT
        md5(concat(c.rkey, '|', c.skey, '|', c.erp, '|', c.ckey))                   AS id,
        c.erp, 0 AS isd, c.rcode, c.rn, c.sn, c.cp, c.colidx, c.rowidx,
        0 AS declared, 2 AS prio, c.ikm
    FROM (
        SELECT
            regexp_replace(regexp_replace(coalesce(s2.structure_row_path, ''), '[ >]+$', ''), '^\\s+|\\s+$', '') AS erp,
            CASE WHEN s2.lb_t <> '' THEN concat(coalesce(s2.rpt_code, ''), '|', s2.lb_t)
                 ELSE coalesce(s2.rpt_code, '') END                                 AS rkey,
            coalesce(s2.sheet_nm, 'None')                                           AS skey,
            coalesce(s2.column_path, 'None')                                        AS ckey,
            coalesce(s2.rpt_code, '')                                               AS rcode,
            coalesce(s2.rpt_nm, '')                                                 AS rn,
            coalesce(s2.sheet_nm, '')                                               AS sn,
            coalesce(s2.column_path, '')                                            AS cp,
            CAST(coalesce(s2.column_index, 0) AS bigint)                            AS colidx,
            CAST(s2.row_index AS bigint)                                            AS rowidx,
            s2.dr_structure_code                                                    AS ikm
        FROM structure_dim s2
        WHERE instr(coalesce(s2.structure_row_path, ''), ' > ...') = 0
            AND s2.srp_t <> '...'
    ) c
),

-- Ưu tiên 3: chỉ tiêu ĐỘNG của mẫu chưa có dữ liệu (đường dẫn hàng chứa ' > ...' hoặc đúng '...')
p3 AS (
    SELECT
        md5(concat(c.rkey, '|', c.skey, '|', c.erp, ' > ...', '|', c.ckey))        AS id,
        c.erp, 1 AS isd, c.rcode, c.rn, c.sn, c.cp, c.colidx, c.rowidx,
        0 AS declared, 3 AS prio, c.ikm
    FROM (
        SELECT
            CASE WHEN s3.srp_t = '...' THEN ''
                 ELSE regexp_replace(regexp_replace(substring_index(s3.srp_t, ' > ...', 1), '[ >]+$', ''),
                                     '^\\s+|\\s+$', '') END                         AS erp,
            CASE WHEN s3.lb_t <> '' THEN concat(coalesce(s3.rpt_code, ''), '|', s3.lb_t)
                 ELSE coalesce(s3.rpt_code, '') END                                 AS rkey,
            coalesce(s3.sheet_nm, 'None')                                           AS skey,
            coalesce(s3.column_path, 'None')                                        AS ckey,
            coalesce(s3.rpt_code, '')                                               AS rcode,
            coalesce(s3.rpt_nm, '')                                                 AS rn,
            coalesce(s3.sheet_nm, '')                                               AS sn,
            coalesce(s3.column_path, '')                                            AS cp,
            CAST(coalesce(s3.column_index, 0) AS bigint)                            AS colidx,
            CAST(s3.row_index AS bigint)                                            AS rowidx,
            s3.dr_structure_code                                                    AS ikm
        FROM structure_dim s3
        WHERE instr(coalesce(s3.structure_row_path, ''), ' > ...') > 0
            OR s3.srp_t = '...'
    ) c
),

-- Lớp 1a: hợp nhất 3 nguồn chỉ tiêu, mỗi indicator_id giữ nguồn ưu tiên cao nhất
unioned AS (
    SELECT id, erp, isd, rcode, rn, sn, cp, colidx, rowidx, declared, prio, ikm,
           row_number() OVER (PARTITION BY id ORDER BY prio, ikm) AS rn_id
    FROM (
        SELECT id, erp, isd, rcode, rn, sn, cp, colidx, rowidx, declared, prio, ikm FROM p1
        UNION ALL
        SELECT id, erp, isd, rcode, rn, sn, cp, colidx, rowidx, declared, prio, ikm FROM p2
        UNION ALL
        SELECT id, erp, isd, rcode, rn, sn, cp, colidx, rowidx, declared, prio, ikm FROM p3
    ) u
),

-- Lớp 1b: nhận diện cột của sheet thuần dòng động (có chỉ tiêu động với đường dẫn hàng rỗng)
indicator_base AS (
    SELECT
        b.*,
        coalesce(max(CASE WHEN b.isd = 1 AND b.erp = '' THEN 1 END) OVER (PARTITION BY b.rn, b.sn, b.cp), 0) AS dyn_col
    FROM unioned b
    WHERE b.rn_id = 1
),

-- Lớp 2a: tên nhóm cơ sở; bỏ chỉ tiêu tĩnh "ma" của sheet thuần dòng động
indicator_l2a AS (
    SELECT
        a.*,
        CASE WHEN a.cp <> '' THEN a.erp
             ELSE array_join(
                      slice(transform(split(a.erp, '>'), p -> regexp_replace(p, '^\\s+|\\s+$', '')),
                            1, size(split(a.erp, '>')) - 1),
                      ' > ')
        END                                                                         AS nhom_base,
        CASE WHEN a.cp <> '' THEN a.cp
             ELSE element_at(transform(split(a.erp, '>'), p -> regexp_replace(p, '^\\s+|\\s+$', '')), -1)
        END                                                                         AS ind_nm,
        array_join(
            CASE WHEN a.isd = 1
                 THEN concat(transform(filter(split(a.erp, ' > '), p -> regexp_replace(p, '^\\s+|\\s+$', '') <> ''),
                                       p -> CASE WHEN regexp_replace(p, '^\\s+|\\s+$', '') = '...' THEN 'Chi tiết' ELSE p END),
                             array('Chi tiết'))
                 ELSE transform(filter(split(a.erp, ' > '), p -> regexp_replace(p, '^\\s+|\\s+$', '') <> ''),
                                p -> CASE WHEN regexp_replace(p, '^\\s+|\\s+$', '') = '...' THEN 'Chi tiết' ELSE p END)
            END,
            ' > ')                                                                  AS rowpath
    FROM indicator_base a
    WHERE NOT (a.isd = 0 AND a.erp = '' AND a.dyn_col = 1)
),

indicator_l2b AS (
    SELECT
        g.*,
        array_join(
            transform(filter(split(g.nhom_base, ' > '), p -> regexp_replace(p, '^\\s+|\\s+$', '') <> ''),
                      p -> CASE WHEN regexp_replace(p, '^\\s+|\\s+$', '') = '...' THEN 'Chi tiết' ELSE p END),
            ' > ')                                                                  AS nhom_norm
    FROM indicator_l2a g
),

indicator_l2 AS (
    SELECT
        h.*,
        array_join(
            filter(array(h.rn, h.sn,
                         CASE WHEN h.isd = 1 THEN CASE WHEN h.nhom_norm <> '' THEN concat(h.nhom_norm, ' > Chi tiết') ELSE 'Chi tiết' END
                              ELSE h.nhom_norm END),
                   g -> g <> ''),
            ' > ')                                                                  AS grp_nm
    FROM indicator_l2b h
),

-- sort_order khi không có row_index: khóa phân cấp theo tối đa 4 đoạn của đường dẫn hàng
-- (số -> 100 + n; chữ cái đầu (không phải chữ số La Mã) / chữ cái -> 0..25; số La Mã -> 26 + giá trị; trống/'...' -> 990; khác -> 999)
sort_seg AS (
    SELECT
        q.id,
        q.pos,
        q.stt,
        concat(
            transform(split(upper(q.stt), ''),
                      c -> CASE c WHEN 'M' THEN 1000 WHEN 'D' THEN 500 WHEN 'C' THEN 100 WHEN 'L' THEN 50
                                  WHEN 'X' THEN 10 WHEN 'V' THEN 5 WHEN 'I' THEN 1 ELSE 0 END),
            array(0, 0))                                                            AS rv
    FROM (
        SELECT
            l.id,
            t.pos,
            regexp_replace(split(t.seg, '-')[0], '^\\s+|\\s+$', '')                 AS stt
        FROM indicator_l2 l
        LATERAL VIEW posexplode(
            slice(CASE WHEN l.erp = '' THEN CAST(array() AS array<string>)
                       ELSE transform(split(l.erp, ' > '), s -> regexp_replace(s, '^\\s+|\\s+$', '')) END,
                  1, 4)
        ) t AS pos, seg
        WHERE l.rowidx IS NULL
    ) q
),

sort_key AS (
    SELECT
        k.id,
        sum(
            CAST(CASE
                WHEN k.stt = '' OR k.stt IN ('...', '-', '—') THEN 990
                WHEN k.stt RLIKE '^[0-9]+$' THEN 100 + coalesce(try_cast(k.stt AS bigint), 0)
                WHEN k.pos = 0 AND k.stt RLIKE '^[ABEFGHJKNOPQRSTUWYZabefghjknopqrstuwyz]$' THEN ascii(upper(k.stt)) - 65
                WHEN upper(k.stt) RLIKE '^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$' THEN
                    26 + aggregate(sequence(1, size(k.rv) - 1), CAST(0 AS bigint),
                                   (acc, j) -> acc + CASE WHEN element_at(k.rv, j) < element_at(k.rv, j + 1)
                                                          THEN -element_at(k.rv, j) ELSE element_at(k.rv, j) END)
                WHEN k.stt RLIKE '^[A-Za-z]$' THEN ascii(upper(k.stt)) - 65
                ELSE 999
            END AS bigint)
            * CASE k.pos WHEN 0 THEN 1000000000 WHEN 1 THEN 1000000 WHEN 2 THEN 1000 ELSE 1 END
        )                                                                           AS seg_sum
    FROM sort_seg k
    GROUP BY k.id
),

indicator_final AS (
    SELECT
        m.*,
        CASE WHEN m.rowidx IS NOT NULL THEN m.rowidx * 1000 + least(m.colidx, 999)
             ELSE coalesce(sk.seg_sum, 0) * 1000 + least(m.colidx, 999) END         AS sort_ord
    FROM indicator_l2 m
    LEFT JOIN sort_key sk
        ON sk.id = m.id
),

-- chỉ tiêu có ít nhất một giá trị CHỮ có nội dung (không ép được sang số) thì là chỉ tiêu chữ
ne AS (
    SELECT DISTINCT vf.indicator_id AS ne_id
    FROM {{ ref('dtm_opr_dynamic_report_explorer_val') }} vf
    WHERE lower(regexp_replace(coalesce(vf.indicator_val, ''), '^\\s+|\\s+$', ''))
              NOT IN ('', '0', '-', '—', '...', 'x', 'n/a', 'none', 'nan')
        AND NOT (regexp_replace(coalesce(vf.indicator_val, ''), '^\\s+|\\s+$', '')
                 RLIKE '(?i)^[+-]?(([0-9]+\\.?[0-9]*|\\.[0-9]+)(e[+-]?[0-9]+)?|inf|infinity)$')
),

-- loại đối tượng đã từng nộp từng báo cáo, dạng |Loại 1|Loại 2| (toàn bộ lịch sử nộp)
ot AS (
    SELECT
        h2.submission_rpt_code                                                      AS ot_rc,
        concat('|', array_join(array_sort(collect_set(regexp_replace(h2.object_tp, '^\\s+|\\s+$', ''))), '|'), '|') AS ot_lst
    FROM submission_hist h2
    WHERE coalesce(h2.submission_rpt_code, '') <> ''
        AND regexp_replace(coalesce(h2.object_tp, ''), '^\\s+|\\s+$', '') <> ''
    GROUP BY h2.submission_rpt_code
),

-- loại quỹ đã từng nộp từng báo cáo (chỉ đối tượng Quỹ đầu tư)
ft AS (
    SELECT
        h3.submission_rpt_code                                                      AS ft_rc,
        concat('|', array_join(array_sort(collect_set(regexp_replace(h3.object_sub_tp, '^\\s+|\\s+$', ''))), '|'), '|') AS ft_lst
    FROM submission_hist h3
    WHERE h3.object_tp = 'Quỹ đầu tư'
        AND coalesce(h3.submission_rpt_code, '') <> ''
        AND regexp_replace(coalesce(h3.object_sub_tp, ''), '^\\s+|\\s+$', '') <> ''
    GROUP BY h3.submission_rpt_code
)

SELECT
    CAST(x.id AS string)                                                            AS indicator_id,
    CAST(x.grp_nm AS string)                                                        AS indicator_group_nm,
    CAST(x.ind_nm AS string)                                                        AS indicator_nm,
    CAST(1 AS int)                                                                  AS indicator_tp,
    CAST('datamart.fct_dynamic_report_val' AS string)                               AS source_table_nm,
    CAST('qlq_opr_dynamic_report_explorer_val_flat' AS string)                      AS target_table_nm,
    CAST('period_end_dt,object_id,object_nm,object_tp,object_sub_tp,rpt_tp_nm,dr_submission_history_code,table_index,dynamic_index,entity_code,custodian_bank_code,period_tp,period_val' AS string)
                                                                                    AS group_key_list,
    CAST('' AS string)                                                              AS logic_function,
    CAST(1 AS int)                                                                  AS indicator_level,
    CAST(1 AS int)                                                                  AS active_ind,
    to_date('2000-01-01')                                                           AS effective_from_dt,
    to_date('2099-12-31')                                                           AS effective_to_dt,
    -- số khi: mọi ô khai báo kiểu số (không phải cột nhãn) và không có giá trị chữ nào; còn lại là chữ
    CAST(CASE WHEN x.declared = 1 AND ne.ne_id IS NULL THEN '' ELSE '__text__' END AS string) AS unit_nm,
    CAST(x.sort_ord AS bigint)                                                      AS sort_order_nbr,
    CAST(x.rn AS string)                                                            AS rpt_nm,
    CAST(x.sn AS string)                                                            AS sheet_nm,
    CAST(x.rowpath AS string)                                                       AS row_path,
    CAST(x.cp AS string)                                                            AS column_path,
    CAST(coalesce(ot.ot_lst, '') AS string)                                         AS object_tp_list,
    CAST(coalesce(ft.ft_lst, '') AS string)                                         AS object_sub_tp_list
FROM indicator_final x
LEFT JOIN ne
    ON ne.ne_id = x.id
LEFT JOIN ot
    ON ot.ot_rc = x.rcode
LEFT JOIN ft
    ON ft.ft_rc = x.rcode
