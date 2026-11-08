-- [FIRST-TIME] ft_dtm_opr_corporate_bond_issuer_credit_monitor: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_opr_corporate_bond_issuer_credit_monitor (config ft_target='opr_corporate_bond_issuer_credit_monitor', ft_scd4a + ft_hstr_by_day, macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_corporate_bond_issuer_credit_monitor
* Program name: Operational Corporate Bond Issuer Credit Monitor (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_opr_corporate_bond_issuer_credit_monitor (ft_scd4a, ft_hstr_by_day):
*									- tra ve snapshot cua NHIEU NGAY (cot ds_snpst_dt = ngay giao dich, dat CUOI SELECT); macro dung _hstr tung ngay + bang chinh = ngay lon nhat.
*									- doc atomic qua ft_ref (ft_atm_security_trading_snapshot / ft_atm_listed_share_information), BO loc etl_date.
*									- 1 dong / ma TP / NGAY: dedupe ban tin cuoi theo (ma, ngay); lsi_hnx noi theo ngay.
*									- BCTC: ky bao cao gan nhat da duyet AS-OF TUNG NGAY (submission_dt <= ngay), rn0/rn1 tinh theo (pc_id, ngay); pivot tinh 1 lan / (pc_id, nam, quy, mau).
*									- Danh muc (atm_public_company, atm_pc_bond_evaluation, chuoi atm_pc_evaluation*): doc bang MAIN ds_rcrd_st='ACTIVE' (khong _hstr theo ngay) ->
*									  GIOI HAN: TCPH/xep hang/y kien kiem toan la gia tri HIEN TAI cho moi ngay lich su; ky xep hang/ky danh gia van lay theo YEAR/MONTH cua tung ngay.
*									- Chong trung khoa (issuer_symbol_code, snpst_dt) cho macro ft: pu_co dedupe theo CAST(pc_code AS bigint) (khong dung pc_id hash),
*									  bond_eval/audit_opinion dedupe theo (pc_id, nam, thang) - daily khong dedupe, chi khac khi nguon trung.
*--------------------------------------------------------------------*
* 2026-11-06		tuan.nguyenvanb		[DOI MAPPING THEO BA 2 cot audit_opinion_text, risk_rating_text] (1) audit_opinion_text: bo chuoi danh gia TAI_CHINH_YKKT; lay y kien kiem toan tu IDS DATA_VALUES (atm_fr_field_value) loc truong FORM_FIELDS co field_format chua AUDITOR_OPINION (atm_fr_x_fr_field_relationship); gia tri = NVL(lookup_value_vn nhom AUDITOR_OPINION (atomic atm_cl_value schema IDS.AUDITOR_OPINION - nguon IDS.LOOKUP_VALUES) hoac text_val); noi qua pc_rpt_submission_code = atm_pc_report_submission.pc_rpt_submission_code; chi lay ho so APPROVED mau HN/TH/ME/RI quy 5 (BCTC nam) va 6 (ban nien); chon ky co ngay ket thuc moi nhat (nam = 31/12 ban nien = 30/06) roi uu tien HN > TH > ME > RI roi submission_dt moi nhat. (2) risk_rating_text: ranking_code A = Binh thuong; B = Canh bao; NULL = Chua co thong tin; con lai = Rui ro (truoc day nhom Thap/Trung binh/Cao/Chua xep hang). Khong doi ten/kieu/vi tri cot -> khong can ALTER; can build lai mart + flat. AS-OF theo ngay (submission_dt <= ngay) nhu chuoi BCTC; atm_cl_value chi co gia tri HIEN TAI nen ten lookup lay theo gia tri hien tai. Can chay truoc ods_ids_data_values, ods_ids_form_fields, ods_ids_lookup_values, atm_fr_field_value, atm_fr_x_fr_field_relationship, atm_cl_value.
* 2026-11-06		tuan.nguyenvanb		[DOI QUY TAC KY BCTC 7 cot tai chinh THEO BA] Chi lay bao cao cua QUY CHUA NGAY GD (QUARTER cua ngay) neu co; khong co thi lui DUNG 1 QUY (Q1 lui ve Q4 nam truoc); van khong co thi NULL (khong lui tiep). Truoc day lay ky gan nhat da duyet bat ke xa bao nhieu. Cach tinh chi so ky = nam * 4 + quy; uu tien HN > TH > ME > RI trong cung ky va rn1 chon ky moi nhat trong 2 ky nhu cu. Anh huong total_liabilities_amt, owner_equity_*_amt, net_profit_after_tax_amt, debt_to_equity_ratio, roe_pct. Khong doi cot -> khong can ALTER; can build lai mart + flat.
* 2026-11-06b		tuan.nguyenvanb		[CHON KY BCTC THEO CO SO LIEU + THEM COT financial_period_end_dt THEO BA] Moi to chuc phat hanh: neu quy chua ngay co SO LIEU (it nhat 1 trong 4 gia tri tong no, VCSH cuoi ky, VCSH dau ky, LNST khac NULL) thi lay quy do; khong co thi lui DUNG 1 quy va lay len bat ke co so lieu hay khong (khong lui tiep). Thay cho ban truoc chon theo co ho so. Them cot financial_period_end_dt (date) = ngay cuoi quy cua so lieu tren dong (luon co gia tri: quy hien tai neu co so lieu, nguoc lai quy lien truoc), dat SAU roe_pct. Mart scd4a insert theo TEN cot nhung can ALTER ADD COLUMN mart + _hstr; flat ClickHouse insert theo VI TRI nen ALTER ADD COLUMN AFTER roe_pct (xem scratch/alter_pttt_bond_monitor_financial_period_20261106.sql).
*/

WITH bond_raw AS (

    SELECT
        ticker_symbol AS symbol
        , ds_snpst_dt AS trading_dt
        , trading_time
        , sequence
        , src_stm_code
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE stock_tp_code = '1'
        AND NOT (
            ticker_symbol RLIKE '^[A-Za-z]{2}GB'
            OR ticker_symbol RLIKE '^(TD|TP|CP|QH|KB|BL)'
            OR ticker_symbol RLIKE '^(HCM|HAN)'
        )

),

bond_snpst AS (

    SELECT
        symbol
        , trading_dt
        , src_stm_code
    FROM (
        SELECT
            bond_raw.*
            , ROW_NUMBER() OVER (
                PARTITION BY bond_raw.symbol, bond_raw.trading_dt   -- [BACKFILL-UAT-NEW] them khoa ngay
                ORDER BY bond_raw.trading_time DESC, bond_raw.sequence DESC
            ) AS rn
        FROM bond_raw
    ) ranked
    WHERE rn = 1

),

lsi_hnx AS (

    SELECT
        ticker_symbol
        , ds_snpst_dt
        , listed_share_quantity
    FROM {{ ft_ref('ft_atm_listed_share_information') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE src_stm_code = 'HNX_LISTED_SECURITIES_LIST'
    -- [BACKFILL-UAT-ORIG]     AND ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')

),

pu_co_all AS (

    SELECT
        pc_id
        , equity_ticker_symbol
        , ROW_NUMBER() OVER (PARTITION BY equity_ticker_symbol ORDER BY CAST(pc_code AS bigint) ASC) AS rn
    FROM {{ ref('atm_public_company') }}   -- [BACKFILL-UAT-NEW] bang MAIN (thay _hstr theo ngay)
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_public_company') }}_hstr ... WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_ticker_symbol IS NOT NULL
        AND pc_code IS NOT NULL

),

pu_co AS (

    SELECT pc_id, equity_ticker_symbol
    FROM pu_co_all
    WHERE rn = 1

),

bond_eval_all AS (

    SELECT
        pc_id
        , ranking_code
        , evaluation_year
        , evaluation_month
        , ROW_NUMBER() OVER (
            PARTITION BY pc_id, evaluation_year, evaluation_month
            ORDER BY ranking_code
        ) AS rn
    FROM {{ ref('atm_pc_bond_evaluation') }}   -- [BACKFILL-UAT-NEW] bang MAIN (thay _hstr theo ngay); ky = nam/thang cua TUNG ngay o buoc noi
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_pc_bond_evaluation') }}_hstr ... WHERE ds_snpst_dt = etl_date AND evaluation_year/month = YEAR/MONTH(etl_date)
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_EVALUATION_CBONDS'

),

bond_eval AS (

    SELECT pc_id, ranking_code, evaluation_year, evaluation_month
    FROM bond_eval_all
    WHERE rn = 1

),

-- === Financial statement chain (BCDKT/BCKQKD gan nhat da duyet) - AS-OF TUNG NGAY ===
pc_rpt_sub_valid AS (

    SELECT
        pc_id
        , rpt_year
        , rpt_quarter
        , fr_code
        , submission_dt
    FROM {{ ref('atm_pc_report_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND approval_status_code = 'APPROVED'
        AND SUBSTR(fr_code,1,2) IN ('HN','TH','ME','RI')
        AND rpt_quarter IN (1,2,3,4)
    -- [BACKFILL-UAT-ORIG]     AND submission_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')   -> chuyen thanh submission_dt <= ngay o sub_asof

),

joined AS (

    SELECT
        bond_snpst.symbol
        , bond_snpst.trading_dt
        , lsi_hnx.listed_share_quantity
        , bond_snpst.src_stm_code
        , pu_co.pc_id
    FROM bond_snpst
    LEFT JOIN lsi_hnx
        ON lsi_hnx.ticker_symbol = bond_snpst.symbol
        AND lsi_hnx.ds_snpst_dt = bond_snpst.trading_dt
    LEFT JOIN pu_co
        ON pu_co.equity_ticker_symbol = SUBSTR(bond_snpst.symbol, 1, 3)

),

days_pc AS (

    SELECT DISTINCT pc_id, trading_dt
    FROM joined
    WHERE pc_id IS NOT NULL

),

sub_asof AS (

    SELECT
        days_pc.pc_id
        , days_pc.trading_dt
        , s.rpt_year
        , s.rpt_quarter
        , s.fr_code
        , s.submission_dt
    FROM days_pc
    INNER JOIN pc_rpt_sub_valid s
        ON s.pc_id = days_pc.pc_id
        AND s.submission_dt <= days_pc.trading_dt   -- [BACKFILL-UAT-NEW] as-of theo ngay (daily: submission_dt <= etl_date)
        AND (s.rpt_year * 4 + s.rpt_quarter) IN (
            YEAR(days_pc.trading_dt) * 4 + QUARTER(days_pc.trading_dt)
            , YEAR(days_pc.trading_dt) * 4 + QUARTER(days_pc.trading_dt) - 1
        )   -- [BACKFILL-UAT-NEW] quy cua ngay hoac lui 1 quy (daily giong het)

),

pc_rpt_sub_ranked AS (

    SELECT
        sub_asof.*
        , ROW_NUMBER() OVER (
            PARTITION BY sub_asof.pc_id, sub_asof.trading_dt, sub_asof.rpt_year, sub_asof.rpt_quarter
            ORDER BY
                CASE SUBSTR(sub_asof.fr_code,1,2)
                    WHEN 'HN' THEN 1
                    WHEN 'TH' THEN 2
                    WHEN 'ME' THEN 3
                    WHEN 'RI' THEN 4
                END
                , sub_asof.submission_dt DESC
        ) AS rn0
    FROM sub_asof

),

pc_rpt_sub_dedup AS (

    SELECT pc_id, trading_dt, rpt_year, rpt_quarter, fr_code
    FROM pc_rpt_sub_ranked
    WHERE rn0 = 1

),

-- === Y kien kiem toan (IDS DATA_VALUES / FORM_FIELDS / LOOKUP_VALUES) - theo BA 2026-11-06 ===
audit_field AS (

    SELECT fr_x_fr_field_rltnp_id
    FROM {{ ref('atm_fr_x_fr_field_relationship') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_FORM_FIELDS'
        AND field_format LIKE '%AUDITOR_OPINION%'

),

audit_val AS (

    SELECT
        fv.pc_rpt_submission_code
        , fv.text_val
    FROM {{ ref('atm_fr_field_value') }} fv
    INNER JOIN audit_field
        ON audit_field.fr_x_fr_field_rltnp_id = fv.fr_x_fr_field_rltnp_id
    WHERE fv.ds_rcrd_st = 'ACTIVE'
        AND fv.src_stm_code = 'IDS_DATA_VALUES'
        AND fv.text_val IS NOT NULL

),

audit_lookup AS (

    SELECT
        cl_code AS lookup_cd
        , cl_nm AS lookup_value_vn
    FROM {{ ref('atm_cl_value') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_LOOKUP_VALUES'
        AND schema_code = 'IDS.AUDITOR_OPINION'

),

audit_sub_all AS (

    SELECT
        s.pc_id
        , s.fr_code
        , s.submission_dt
        , s.pc_rpt_submission_code
        , CASE WHEN s.rpt_quarter = 5 THEN make_date(s.rpt_year, 12, 31) ELSE make_date(s.rpt_year, 6, 30) END AS period_end_dt
        , NVL(audit_lookup.lookup_value_vn, audit_val.text_val) AS audit_opinion_text
    FROM (
        SELECT pc_id, rpt_year, rpt_quarter, fr_code, submission_dt, pc_rpt_submission_code
        FROM {{ ref('atm_pc_report_submission') }}
        WHERE ds_rcrd_st = 'ACTIVE'
            AND approval_status_code = 'APPROVED'
            AND SUBSTR(fr_code,1,2) IN ('HN','TH','ME','RI')
            AND rpt_quarter IN (5,6)
    ) s
    INNER JOIN audit_val
        ON audit_val.pc_rpt_submission_code = s.pc_rpt_submission_code
    LEFT JOIN audit_lookup
        ON audit_lookup.lookup_cd = audit_val.text_val

),

audit_sub_asof AS (

    SELECT
        days_pc.trading_dt
        , a.*
    FROM days_pc
    INNER JOIN audit_sub_all a
        ON a.pc_id = days_pc.pc_id
        AND a.submission_dt <= days_pc.trading_dt

),

audit_opinion_ranked AS (

    SELECT
        audit_sub_asof.*
        , ROW_NUMBER() OVER (
            PARTITION BY audit_sub_asof.pc_id, audit_sub_asof.trading_dt
            ORDER BY
                audit_sub_asof.period_end_dt DESC
                , CASE SUBSTR(audit_sub_asof.fr_code,1,2)
                    WHEN 'HN' THEN 1
                    WHEN 'TH' THEN 2
                    WHEN 'ME' THEN 3
                    WHEN 'RI' THEN 4
                END
                , audit_sub_asof.submission_dt DESC
                , CAST(audit_sub_asof.pc_rpt_submission_code AS bigint) DESC
        ) AS rn
    FROM audit_sub_asof

),

audit_opinion AS (

    SELECT pc_id, trading_dt, audit_opinion_text
    FROM audit_opinion_ranked
    WHERE rn = 1

),

-- pivot tinh 1 lan cho moi (pc_id, nam, quy, mau) duoc chon o it nhat 1 ngay, khong lap lai theo ngay
sub_period AS (

    SELECT DISTINCT pc_id, rpt_year, rpt_quarter, fr_code
    FROM pc_rpt_sub_dedup

),

fin_value_joined AS (

    SELECT
        s.pc_id
        , s.rpt_year
        , s.rpt_quarter
        , s.fr_code
        , fc.rpt_code
        , fc.enterprise_tp_code
        , frt.row_description_reference
        , fclt.column_description_reference
        , fv.cell_val
    FROM sub_period s
    INNER JOIN {{ ref('atm_fr_value') }} fv
        ON fv.pc_id = s.pc_id
        AND fv.rpt_year = s.rpt_year
        AND fv.rpt_quarter = s.rpt_quarter
        AND fv.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON fc.fr_catalog_id = fv.fr_catalog_id
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(s.fr_code,1,2)
        AND (fc.rpt_code LIKE 'BCDKT%' OR fc.rpt_code LIKE 'BCKQKD%')
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON frt.row_code = fv.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.ds_rcrd_st = 'ACTIVE'

),

fin_pivot AS (

    SELECT
        fin_value_joined.pc_id
        , fin_value_joined.rpt_year
        , fin_value_joined.rpt_quarter
        , fin_value_joined.fr_code
        , MAX(CASE
            WHEN fin_value_joined.rpt_code LIKE 'BCDKT%'
                AND (
                    (fin_value_joined.enterprise_tp_code IN ('DN','BH') AND fin_value_joined.row_description_reference = '300')
                    OR (fin_value_joined.enterprise_tp_code = 'TD' AND fin_value_joined.row_description_reference = '400')
                )
                AND fin_value_joined.column_description_reference = '1'
            THEN fin_value_joined.cell_val
          END) AS total_liabilities_amt
        , MAX(CASE
            WHEN fin_value_joined.rpt_code LIKE 'BCDKT%'
                AND (
                    (fin_value_joined.enterprise_tp_code IN ('DN','BH') AND fin_value_joined.row_description_reference = '400')
                    OR (fin_value_joined.enterprise_tp_code = 'TD' AND fin_value_joined.row_description_reference = '500')
                )
                AND fin_value_joined.column_description_reference = '1'
            THEN fin_value_joined.cell_val
          END) AS owner_equity_ending_amt
        , MAX(CASE
            WHEN fin_value_joined.rpt_code LIKE 'BCDKT%'
                AND (
                    (fin_value_joined.enterprise_tp_code IN ('DN','BH') AND fin_value_joined.row_description_reference = '400')
                    OR (fin_value_joined.enterprise_tp_code = 'TD' AND fin_value_joined.row_description_reference = '500')
                )
                AND fin_value_joined.column_description_reference = '2'
            THEN fin_value_joined.cell_val
          END) AS owner_equity_beginning_amt
        , MAX(CASE
            WHEN fin_value_joined.rpt_code LIKE 'BCKQKD%'
                AND (
                    (fin_value_joined.enterprise_tp_code IN ('DN','BH') AND fin_value_joined.row_description_reference = '60')
                    OR (fin_value_joined.enterprise_tp_code = 'TD' AND fin_value_joined.row_description_reference = '21')
                )
                AND fin_value_joined.column_description_reference = '1'
            THEN fin_value_joined.cell_val
          END) AS net_profit_after_tax_amt
    FROM fin_value_joined
    GROUP BY
        fin_value_joined.pc_id
        , fin_value_joined.rpt_year
        , fin_value_joined.rpt_quarter
        , fin_value_joined.fr_code

),

-- [2026-11-06 THEO BA] toi da 2 ky ung vien moi (to chuc, ngay): quy chua ngay (is_cur) va quy lien truoc
fin_candidate AS (

    SELECT
        d.pc_id
        , d.trading_dt
        , d.rpt_year
        , d.rpt_quarter
        , (d.rpt_year * 4 + d.rpt_quarter = YEAR(d.trading_dt) * 4 + QUARTER(d.trading_dt)) AS is_cur
        , fin_pivot.total_liabilities_amt
        , fin_pivot.owner_equity_ending_amt
        , fin_pivot.owner_equity_beginning_amt
        , fin_pivot.net_profit_after_tax_amt
        , (
            fin_pivot.total_liabilities_amt IS NOT NULL
            OR fin_pivot.owner_equity_ending_amt IS NOT NULL
            OR fin_pivot.owner_equity_beginning_amt IS NOT NULL
            OR fin_pivot.net_profit_after_tax_amt IS NOT NULL
        ) AS has_data
    FROM pc_rpt_sub_dedup d
    LEFT JOIN fin_pivot
        ON fin_pivot.pc_id = d.pc_id
        AND fin_pivot.rpt_year = d.rpt_year
        AND fin_pivot.rpt_quarter = d.rpt_quarter
        AND fin_pivot.fr_code = d.fr_code

),

fin_choice AS (

    SELECT
        pc_id
        , trading_dt
        , MAX(CASE WHEN is_cur AND has_data THEN 1 ELSE 0 END) AS cur_has_data
    FROM fin_candidate
    GROUP BY pc_id, trading_dt

),

fin_ratios AS (

    SELECT
        c.pc_id
        , c.trading_dt
        , c.rpt_year
        , c.rpt_quarter
        , c.total_liabilities_amt
        , c.owner_equity_ending_amt
        , c.owner_equity_beginning_amt
        , CASE
            WHEN c.owner_equity_beginning_amt IS NULL THEN c.owner_equity_ending_amt
            ELSE (c.owner_equity_beginning_amt + c.owner_equity_ending_amt) / 2
          END AS owner_equity_average_amt
        , c.net_profit_after_tax_amt
    FROM fin_candidate c
    INNER JOIN fin_choice ch
        ON ch.pc_id = c.pc_id
        AND ch.trading_dt = c.trading_dt
    WHERE (ch.cur_has_data = 1 AND c.is_cur)
        OR (ch.cur_has_data = 0 AND NOT c.is_cur)

)


SELECT
    CAST(joined.symbol AS string)                              AS issuer_symbol_code,
    CAST(joined.trading_dt AS date)                             AS snpst_dt,
    CAST(100000 * joined.listed_share_quantity AS decimal(23,2)) AS bond_outstanding_val,
    CAST(100000 AS decimal(23,2))                               AS par_val,
    CAST(joined.listed_share_quantity AS decimal(23,2))    AS outstanding_vol,
    CAST(audit_opinion.audit_opinion_text AS string)            AS audit_opinion_text,
    CAST(bond_eval.ranking_code AS string)                      AS ranking_code,
    CAST(
        CASE
            WHEN bond_eval.ranking_code IN ('A') THEN 'Bình thường'
            WHEN bond_eval.ranking_code IN ('B') THEN 'Cảnh báo'
            WHEN bond_eval.ranking_code IS NULL THEN 'Chưa có thông tin'
            ELSE 'Rủi ro'
        END
    AS string)                                                  AS risk_rating_text,
    CAST(fin_ratios.total_liabilities_amt AS decimal(23,2))     AS total_liabilities_amt,
    CAST(fin_ratios.owner_equity_ending_amt AS decimal(23,2))   AS owner_equity_ending_amt,
    CAST(fin_ratios.owner_equity_beginning_amt AS decimal(23,2)) AS owner_equity_beginning_amt,
    CAST(fin_ratios.owner_equity_average_amt AS decimal(23,2)) AS owner_equity_average_amt,
    CAST(fin_ratios.net_profit_after_tax_amt AS decimal(23,2)) AS net_profit_after_tax_amt,
    CAST(
        fin_ratios.total_liabilities_amt / NULLIF(fin_ratios.owner_equity_ending_amt, 0)
    AS decimal(8,2))                                            AS debt_to_equity_ratio,
    CAST(
        ROUND(fin_ratios.net_profit_after_tax_amt / NULLIF(fin_ratios.owner_equity_average_amt, 0) * 100, 4)
    AS decimal(8,4))                                            AS roe_pct,
    CAST(last_day(make_date(COALESCE(fin_ratios.rpt_year, CASE WHEN QUARTER(joined.trading_dt) = 1 THEN YEAR(joined.trading_dt) - 1 ELSE YEAR(joined.trading_dt) END), COALESCE(fin_ratios.rpt_quarter, CASE WHEN QUARTER(joined.trading_dt) = 1 THEN 4 ELSE QUARTER(joined.trading_dt) - 1 END) * 3, 1)) AS date) AS financial_period_end_dt,
    date_format(joined.trading_dt, 'yyyy-MM-dd')                AS data_dt,   -- [BACKFILL-UAT-NEW] = ngay snapshot (daily: = etl_date)
    CAST(joined.src_stm_code AS string)                         AS src_stm_code,
    CAST(joined.trading_dt AS date)                             AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] ngay snapshot (ft_hstr_by_day)
FROM joined
LEFT JOIN bond_eval
    ON bond_eval.pc_id = joined.pc_id
    AND bond_eval.evaluation_year = YEAR(joined.trading_dt)
    AND bond_eval.evaluation_month = MONTH(joined.trading_dt)
LEFT JOIN audit_opinion
    ON audit_opinion.pc_id = joined.pc_id
    AND audit_opinion.trading_dt = joined.trading_dt
LEFT JOIN fin_ratios
    ON fin_ratios.pc_id = joined.pc_id
    AND fin_ratios.trading_dt = joined.trading_dt
