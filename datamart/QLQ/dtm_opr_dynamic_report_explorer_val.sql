/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_dynamic_report_explorer_val
* Program name: Dtm Operational Dynamic Report Explorer Value (Data Explorer QLQ - báo cáo động FMS)
* Created by: claude (sync)
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		claude (sync)		Tạo mới theo LLD DTM_QLQ_opr_dynamic_report_explorer_val_*.csv — port Spark SQL từ
*                                       Datamart/flat-table/QLQ/02_populate_qlq_flat_tables.sql khối 21 (bản ClickHouse).
*                                       Thay nguồn: fct_dynamic_report_val + cdr_dt_dim -> Atomic dr_value (ngày nộp = submission_dt);
*                                       dynamic_report_structure_dim / submission_history_dim -> bản _hstr snapshot etl_date.
*                                       Nạp TOÀN BỘ mỗi lần chạy (O_QLQ_80) — incremental_rebase append không partition_by
*                                       => INSERT OVERWRITE cả bảng. Bảng CHƯA có PK (chờ Data Modeler chốt).
*                                       Khác biệt ở biên so với ClickHouse (indicator_val số):
*                                         - |giá trị| >= 1e16 không phải số nguyên: Spark in dạng 1.0E16, ClickHouse in 1e16;
*                                         - số có > 18 chữ số thập phân bị làm tròn tới 18 chữ số.
*--------------------------------------------------------------------*
*/

WITH dr_value AS (
    SELECT
        dr_val_id,
        dr_structure_code,
        dr_submission_history_code,
        row_dynamic_index,
        entity_code,
        label_column_ind,
        val,
        custodian_bank_code,
        dynamic_ind,
        data_tp,
        submission_dt
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
        legal_basis
    FROM {{ ref('dtm_dynamic_report_structure_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

-- Lần nộp thắng: mỗi nhóm (đối tượng, báo cáo, loại kỳ, kỳ) chỉ giữ lần nộp có rpt_version cao nhất
-- (NULL = thấp nhất; cùng version cao nhất thì giữ tất cả). Xét TOÀN BỘ lịch sử nộp.
submission_ver AS (
    SELECT
        dr_submission_history_code,
        object_id,
        object_nm,
        object_tp,
        object_sub_tp,
        rpt_tp,
        period_tp,
        period_val,
        coalesce(CAST(rpt_version AS bigint), -9223372036854775807) AS ver,
        max(coalesce(CAST(rpt_version AS bigint), -9223372036854775807)) OVER (
            PARTITION BY coalesce(object_id, ''), coalesce(submission_rpt_code, ''),
                         coalesce(period_tp, ''), coalesce(period_val, '')
        ) AS best_ver
    FROM {{ ref('dtm_dynamic_report_submission_history_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

submission_win AS (
    SELECT
        dr_submission_history_code AS log_id,
        object_id,
        object_nm,
        object_tp,
        object_sub_tp,
        rpt_tp,
        period_tp,
        period_val
    FROM submission_ver
    WHERE ver = best_ver
),

-- Lớp 1a: ghép giá trị với cấu trúc (loại chỉ tiêu mồ côi) và lần nộp thắng; chuẩn hóa chuỗi
base_raw AS (
    SELECT
        f.dr_val_id                                                                     AS dr_val_id,
        f.dr_submission_history_code                                                    AS log_id,
        f.submission_dt                                                                 AS nop,
        CAST(coalesce(f.row_dynamic_index, 0) AS bigint)                                AS ro,
        CAST(coalesce(f.row_dynamic_index, -1) AS bigint)                               AS ro_raw,
        coalesce(f.dynamic_ind, 0) = 1                                                  AS is_dyn,
        coalesce(f.label_column_ind, 0) = 1                                             AS is_label,
        regexp_replace(coalesce(f.custodian_bank_code, ''), '^\\s+|\\s+$', '')          AS accs,
        coalesce(f.custodian_bank_code, '')                                             AS accs_raw,
        lower(regexp_replace(coalesce(f.data_tp, ''), '^\\s+|\\s+$', ''))               AS kd,
        regexp_replace(coalesce(f.val, ''), '^\\s+|\\s+$', '')                          AS vt,
        regexp_replace(coalesce(f.entity_code, ''), '^\\s+|\\s+$', '')                  AS ent_t,
        regexp_replace(coalesce(s.structure_row_path, ''), '^\\s+|\\s+$', '')           AS srp_t,
        coalesce(s.structure_row_path, '')                                              AS srp_raw,
        regexp_replace(coalesce(s.legal_basis, ''), '^\\s+|\\s+$', '')                  AS lb_t,
        -- khóa md5: sheet/column NULL viết 'None' như job cũ (giữ nguyên id đã lưu)
        coalesce(s.sheet_nm, 'None')                                                    AS skey,
        coalesce(s.column_path, 'None')                                                 AS ckey,
        s.rpt_code                                                                      AS rpt_code,
        s.rpt_nm                                                                        AS rpt_nm,
        w.object_id                                                                     AS object_id,
        w.object_nm                                                                     AS object_nm,
        w.object_tp                                                                     AS object_tp,
        w.object_sub_tp                                                                 AS object_sub_tp,
        w.period_tp                                                                     AS period_tp,
        w.period_val                                                                    AS period_val,
        try_cast(regexp_replace(coalesce(w.rpt_tp, ''), '^\\s+|\\s+$', '') AS double)   AS rtp_f,
        upper(regexp_replace(coalesce(w.period_tp, ''), '^\\s+|\\s+$', ''))             AS period_tp_u,
        upper(regexp_replace(coalesce(w.period_val, ''), '^\\s+|\\s+$', ''))            AS period_val_u
    FROM dr_value f
    INNER JOIN structure_dim s
        ON s.dr_structure_code = f.dr_structure_code
    INNER JOIN submission_win w
        ON w.log_id = f.dr_submission_history_code
),

-- Lớp 1b: cột cơ sở (mã thực thể, đường dẫn hàng hiệu lực, khóa báo cáo, tuần ISO)
base AS (
    SELECT
        b.*,
        CASE WHEN b.is_dyn
                  AND b.ent_t <> ''
                  AND lower(b.ent_t) NOT IN ('...', '0')
                  AND NOT (b.ent_t RLIKE '^[. ]+$')
             THEN b.ent_t ELSE '' END                                                   AS entity_base,
        -- effective_row_path: dòng động = đường dẫn mẫu cắt trước ' > ...'; dòng tĩnh = đường dẫn mẫu nguyên văn
        CASE WHEN b.is_dyn THEN
                 CASE WHEN b.srp_t = '...' THEN ''
                      ELSE regexp_replace(regexp_replace(substring_index(b.srp_t, ' > ...', 1), '[ >]+$', ''),
                                          '^\\s+|\\s+$', '') END
             ELSE b.srp_raw END                                                         AS erp,
        -- legal_basis (nếu có) gắn vào mã báo cáo
        CASE WHEN b.lb_t <> '' THEN concat(coalesce(b.rpt_code, ''), '|', b.lb_t)
             ELSE coalesce(b.rpt_code, '') END                                          AS rkey,
        CASE WHEN b.period_tp_u = 'TUAN' AND b.period_val_u RLIKE '^TU[0-9]{1,2}/[0-9]{4}$'
             THEN CAST(regexp_extract(b.period_val_u, '^TU([0-9]{1,2})/([0-9]{4})$', 1) AS int) END AS tu_w,
        CASE WHEN b.period_tp_u = 'TUAN' AND b.period_val_u RLIKE '^TU[0-9]{1,2}/[0-9]{4}$'
             THEN CAST(regexp_extract(b.period_val_u, '^TU([0-9]{1,2})/([0-9]{4})$', 2) AS int) END AS tu_y,
        -- pkind = 1: lấy ngày cuối THÁNG của pstr (THANG, QUY, 6_THANG, nửa tháng thứ hai); 0: dùng đúng ngày pstr
        CASE WHEN b.period_tp_u IN ('THANG', 'QUY', '6_THANG') THEN 1
             WHEN b.period_tp_u = 'NUA_THANG' AND b.period_val_u LIKE 'NT2%' THEN 1
             ELSE 0 END                                                                 AS pkind
    FROM base_raw b
),

-- Chủ nhật của tuần ISO tu_w năm tu_y: thứ Hai của tuần chứa 04/01 + (tu_w - 1) * 7 + 6
base_week AS (
    SELECT
        bw.*,
        CASE WHEN bw.tu_w IS NOT NULL THEN
            date_add(date_sub(make_date(bw.tu_y, 1, 4), (dayofweek(make_date(bw.tu_y, 1, 4)) + 5) % 7),
                     (bw.tu_w - 1) * 7 + 6)
        END                                                                             AS tu_end
    FROM base bw
),

-- Lớp 1c: pstr = chuỗi ngày ứng viên của ngày cuối kỳ (rỗng nếu kỳ không parse được)
base_period AS (
    SELECT
        bp.*,
        CASE
            WHEN bp.period_tp_u = 'THANG' AND bp.period_val_u RLIKE '^T[0-9]{1,2}/[0-9]{4}$' THEN
                concat(regexp_extract(bp.period_val_u, '^T([0-9]{1,2})/([0-9]{4})$', 2), '-',
                       lpad(regexp_extract(bp.period_val_u, '^T([0-9]{1,2})/([0-9]{4})$', 1), 2, '0'), '-01')
            WHEN bp.period_tp_u = 'QUY' AND bp.period_val_u RLIKE '^Q[1-4]/[0-9]{4}$' THEN
                concat(regexp_extract(bp.period_val_u, '^Q([1-4])/([0-9]{4})$', 2), '-',
                       lpad(CAST(CAST(regexp_extract(bp.period_val_u, '^Q([1-4])/([0-9]{4})$', 1) AS int) * 3 AS string), 2, '0'),
                       '-01')
            WHEN bp.period_tp_u = '6_THANG' AND bp.period_val_u RLIKE '^6T[12]/[0-9]{4}$' THEN
                concat(regexp_extract(bp.period_val_u, '^6T([12])/([0-9]{4})$', 2), '-',
                       CASE WHEN regexp_extract(bp.period_val_u, '^6T([12])/([0-9]{4})$', 1) = '1' THEN '06' ELSE '12' END,
                       '-01')
            WHEN bp.period_tp_u = 'NAM' AND bp.period_val_u RLIKE '^NAM_[0-9]{4}$' THEN
                concat(regexp_extract(bp.period_val_u, '^NAM_([0-9]{4})$', 1), '-12-31')
            WHEN bp.period_tp_u = 'NGAY' AND bp.period_val_u RLIKE '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}' THEN
                concat(regexp_extract(bp.period_val_u, '^([0-9]{1,2})/([0-9]{1,2})/([0-9]{4})', 3), '-',
                       lpad(regexp_extract(bp.period_val_u, '^([0-9]{1,2})/([0-9]{1,2})/([0-9]{4})', 2), 2, '0'), '-',
                       lpad(regexp_extract(bp.period_val_u, '^([0-9]{1,2})/([0-9]{1,2})/([0-9]{4})', 1), 2, '0'))
            WHEN bp.period_tp_u = 'NUA_THANG' AND bp.period_val_u RLIKE '^NT[12]/[0-9]{1,2}/[0-9]{4}$' THEN
                concat(regexp_extract(bp.period_val_u, '^NT([12])/([0-9]{1,2})/([0-9]{4})$', 3), '-',
                       lpad(regexp_extract(bp.period_val_u, '^NT([12])/([0-9]{1,2})/([0-9]{4})$', 2), 2, '0'),
                       CASE WHEN regexp_extract(bp.period_val_u, '^NT([12])/([0-9]{1,2})/([0-9]{4})$', 1) = '1' THEN '-15' ELSE '-01' END)
            -- tuần ISO hợp lệ: năm ISO (= năm của thứ Năm cùng tuần) và số tuần ISO của ngày cuối tuần khớp đầu vào
            WHEN bp.tu_end IS NOT NULL
                 AND year(date_sub(bp.tu_end, 3)) = bp.tu_y
                 AND weekofyear(bp.tu_end) = bp.tu_w THEN
                CAST(bp.tu_end AS string)
            ELSE ''
        END                                                                             AS pstr
    FROM base_week bp
),

-- Lớp 2a: table_index (BA: TABLE_IDX), dup_mask
idx AS (
    SELECT
        i.*,
        CASE WHEN size(collect_set(CASE WHEN NOT i.is_dyn THEN i.ro END) OVER (PARTITION BY i.log_id, i.skey)) > 1
             THEN CASE WHEN i.is_dyn THEN CAST(floor(i.ro / 1000) AS bigint) ELSE i.ro END
             ELSE CAST(0 AS bigint) END                                                 AS table_index,
        i.is_dyn AND NOT (i.entity_base RLIKE '^Tổng-[0-9]+$')                          AS dup_mask
    FROM base_period i
),

-- Lớp 2: dynamic_index (BA: DYNAMIC_IDX); đánh số dòng trùng mã (dense_rank theo row_order)
-- trong cùng lần nộp / bảng / TK / mục / mã
ranked AS (
    SELECT
        r.*,
        CASE WHEN r.is_dyn THEN r.ro - r.table_index * 1000 ELSE CAST(-1 AS bigint) END AS dynamic_index,
        dense_rank() OVER (
            PARTITION BY r.log_id, r.table_index, r.accs_raw, r.erp, r.entity_base, r.dup_mask
            ORDER BY r.ro_raw
        )                                                                               AS rk
    FROM idx r
),

-- Lớp 3: khóa nghiệp vụ, ngày cuối kỳ, nhãn loại báo cáo, giá trị chuỗi
enriched AS (
    SELECT
        e.*,
        CASE WHEN e.dup_mask AND e.rk >= 2 THEN concat(e.entity_base, '#', CAST(e.rk AS string))
             ELSE e.entity_base END                                                     AS entity_code_final,
        CASE WHEN e.accs IN ('', '0', 'nan', 'none') THEN '' ELSE e.accs END            AS acc_clean,
        CASE WHEN e.vt <> '' AND lower(e.vt) NOT IN ('none', 'nan', '...') THEN e.vt
             ELSE '0' END                                                               AS txt_val,
        CASE
            WHEN e.rtp_f IS NULL THEN ''
            WHEN CAST(e.rtp_f AS bigint) = 1 THEN 'Báo cáo định kỳ'
            WHEN CAST(e.rtp_f AS bigint) = 2 THEN 'Báo cáo bất thường'
            WHEN CAST(e.rtp_f AS bigint) = 3 THEN 'Báo cáo theo yêu cầu'
            WHEN CAST(e.rtp_f AS bigint) = 4 THEN 'Báo cáo khác'
            ELSE ''
        END                                                                             AS rpt_tp_nm,
        md5(concat(e.rkey, '|', e.skey, '|',
                   CASE WHEN e.is_dyn THEN concat(e.erp, ' > ...') ELSE e.erp END,
                   '|', e.ckey))                                                        AS ind_base,
        md5(concat(e.rkey, '|', e.skey, '|', concat(e.erp, ' > Chi tiết > ...'), '|', e.ckey)) AS ind_alias,
        -- ngày cuối kỳ: kiểm tra khứ hồi chuỗi -> ngày -> chuỗi (ngày không tồn tại như 2026-02-31 => lấy ngày nộp)
        CASE WHEN e.pstr <> '' AND CAST(try_cast(e.pstr AS date) AS string) = e.pstr THEN
                 CASE WHEN e.pkind = 1 THEN last_day(try_cast(e.pstr AS date))
                      ELSE try_cast(e.pstr AS date) END
        END                                                                             AS pend
    FROM ranked e
),

-- Dòng động 'Tổng-N' sinh thêm 1 bản ghi cho chỉ tiêu alias '... > Chi tiết > ...'
exploded AS (
    SELECT
        x.*,
        t.indicator_id
    FROM enriched x
    LATERAL VIEW explode(
        CASE WHEN x.is_dyn AND x.entity_code_final RLIKE '^Tổng-[0-9]+$'
             THEN array(x.ind_base, x.ind_alias)
             ELSE array(x.ind_base) END
    ) t AS indicator_id
),

final AS (
    SELECT
        coalesce(z.pend, z.nop)                                                         AS period_end_dt,
        coalesce(z.object_id, '')                                                       AS object_id,
        coalesce(z.object_nm, '')                                                       AS object_nm,
        coalesce(z.object_tp, '')                                                       AS object_tp,
        coalesce(z.object_sub_tp, '')                                                   AS object_sub_tp,
        z.rpt_tp_nm                                                                     AS rpt_tp_nm,
        coalesce(z.period_tp, '')                                                       AS period_tp,
        coalesce(z.period_val, '')                                                      AS period_val,
        z.table_index                                                                   AS table_index,
        z.dynamic_index                                                                 AS dynamic_index,
        z.entity_code_final                                                             AS entity_code,
        z.acc_clean                                                                     AS custodian_bank_code,
        z.indicator_id                                                                  AS indicator_id,
        CASE
            WHEN z.is_label THEN z.entity_base
            WHEN z.kd IN ('string', 'datasource') THEN z.txt_val
            WHEN z.vt RLIKE '^[+-]?([0-9]+\\.?[0-9]*|\\.[0-9]+)([eE][+-]?[0-9]+)?$' THEN
                CASE
                    -- số nguyên trong dải bigint
                    WHEN z.vt RLIKE '^[+-]?[0-9]+$' AND try_cast(z.vt AS bigint) IS NOT NULL
                        THEN CAST(try_cast(z.vt AS bigint) AS string)
                    -- số nguyên dương trong dải UInt64 (ClickHouse toUInt64)
                    WHEN z.vt RLIKE '^\\+?[0-9]+$'
                         AND try_cast(regexp_replace(z.vt, '^[+]', '') AS decimal(38,0)) <= 18446744073709551615
                        THEN CAST(try_cast(regexp_replace(z.vt, '^[+]', '') AS decimal(38,0)) AS string)
                    -- số thực: dạng ngắn nhất của Float64, số nguyên thêm '.0' (như toString(Float64) của job cũ)
                    WHEN abs(try_cast(z.vt AS double)) < 1e16
                        THEN regexp_replace(
                                 regexp_replace(
                                     CAST(CAST(CAST(try_cast(z.vt AS double) AS string) AS decimal(38,18)) AS string),
                                     '0+$', ''),
                                 '[.]$', '.0')
                    ELSE CAST(try_cast(z.vt AS double) AS string)
                END
            ELSE z.txt_val
        END                                                                             AS indicator_val,
        coalesce(z.rpt_code, '')                                                        AS rpt_code,
        coalesce(z.rpt_nm, '')                                                          AS rpt_nm,
        z.log_id                                                                        AS dr_submission_history_code,
        z.nop                                                                           AS nop,
        z.dr_val_id                                                                     AS dr_val_id
    FROM exploded z
),

-- Khử trùng theo khóa ORDER BY của bảng flat: giữ bản có ngày nộp mới nhất (hòa thì dr_val_id lớn nhất)
dedup AS (
    SELECT
        d.*,
        row_number() OVER (
            PARTITION BY d.period_end_dt, d.object_id, d.period_tp, d.period_val, d.dr_submission_history_code,
                         d.table_index, d.entity_code, d.custodian_bank_code, d.indicator_id
            ORDER BY d.nop DESC, d.dr_val_id DESC
        ) AS rn
    FROM final d
)

SELECT
    CAST(dedup.period_end_dt AS date)                   AS period_end_dt,
    CAST(dedup.object_id AS string)                     AS object_id,
    CAST(dedup.object_nm AS string)                     AS object_nm,
    CAST(dedup.object_tp AS string)                     AS object_tp,
    CAST(dedup.object_sub_tp AS string)                 AS object_sub_tp,
    CAST(dedup.rpt_tp_nm AS string)                     AS rpt_tp_nm,
    CAST(dedup.period_tp AS string)                     AS period_tp,
    CAST(dedup.period_val AS string)                    AS period_val,
    CAST(dedup.table_index AS int)                      AS table_index,
    CAST(dedup.dynamic_index AS int)                    AS dynamic_index,
    CAST(dedup.entity_code AS string)                   AS entity_code,
    CAST(dedup.custodian_bank_code AS string)           AS custodian_bank_code,
    CAST(dedup.indicator_id AS string)                  AS indicator_id,
    CAST(dedup.indicator_val AS string)                 AS indicator_val,
    CAST(dedup.rpt_code AS string)                      AS rpt_code,
    CAST(dedup.rpt_nm AS string)                        AS rpt_nm,
    CAST(dedup.dr_submission_history_code AS string)    AS dr_submission_history_code
FROM dedup
WHERE dedup.rn = 1
