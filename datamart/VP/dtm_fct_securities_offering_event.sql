/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_offering_event
* Program name: Dtm Fct Securities Offering Event
* Created by: huy.pham
* Created date: 2026-11-11
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-11      huy.pham        [MOI, O_VP_75] Fact sự kiện phát hành chứng khoán.
*                                 Grain = 1 đợt phát hành × 1 phương thức × 1 loại CK × 1 kỳ kết quả.
*                                 3 nguồn UNION ALL: IDS (CTĐC), SCMS (CTCK – CHỜ ATOMIC),
*                                 FMS (CTQLQ). Full history: certificate_dt <= etl_date.
*                                 Nạp toàn bộ lịch sử, MERGE by PK.
* 2026-11-11      huy.pham        [SỬA, O_VP_77(f)] Cập nhật PK: thêm security_tp_code, par_val,
*                                 offering_price, result_rpt_dt, offering_end_dt để đảm bảo duy nhất
*                                 khi 1 đợt có nhiều phương án giá/mệnh giá hoặc nhiều kỳ kết quả.
*                                 IDS offering_code = pc_securities_offering_code.
*                                 certificate_nbr = COALESCE(certificate_nbr, official_letter_nbr).
*                                 offering_round_key = concat_ws(issuer_tp|business_reg_no|cert_nbr|cert_dt).
*                                 plan_amt = CASE tính từ total_expected_amt hoặc price × qty.
*                                 ids_result_agg: lọc APPROVED, giữ grain result_rpt_dt × offering_end_dt.
*                                 FMS offering_code = fmc_securities_offering_code.
*                                 FMS plan: thêm filter src_stm_code = 'FMS_OFFERING_PLAN'.
* 2026-11-16      claude          [SỬA, O_VP_77(f)] offering_round_key FMS: NULL -> tính
*                                 concat_ws('|','CTQLQ',fmc_code,COALESCE(cert_nbr,'0'),cert_dt).
* 2026-11-18      claude          [SỬA, O_VP_78] SCMS: thêm scms_item_agg CTE từ
*                                 atm_sc_disclosure_securities_offering_item, INNER JOIN
*                                 vào scms_base. offering_method_code, plan_qty, plan_amt,
*                                 result_qty, result_amt, result_val_amt đọc từ item thay
*                                 vì header. has_result_ind = sci.has_actual.
*                                 Grain mở rộng: 1 header x N offering_method (item).
* 2026-11-16      claude          [SỬA, O_VP_75] Uncomment SCMS branch: thêm scms_base CTE
*                                 từ atm_sc_disclosure_securities_offering (event table, không
*                                 _hstr). Mapping: document_nbr->cert_nbr, COALESCE(document_dt,
*                                 src_record_insert_tms)->cert_dt, item_category_code->
*                                 security_tp_code. industry_code = '07000'. security_nm = NULL.
* 2026-11-16      claude          [SỬA, O_VP_75] Thêm các cột theo LLD: offering_method_code,
*                                 offering_method_group_code, raising_capital_ind, has_result_ind,
*                                 bond_term_years, issue_interest_rate, industry_code,
*                                 result_val_amt, foreign_result_val_amt. Xóa par_val,
*                                 offering_price, offering_end_dt khỏi output (giữ trong combined
*                                 cho PK hash). Sửa result_val_amt IDS có fallback price × qty.
*                                 Thêm: foreign_collected_amt vào ids_result_agg (rename
*                                 result_amt -> result_amt_orig), bond_term_val/interest_rate
*                                 vào ids_plan_agg, bond_term_years vào fms_base,
*                                 foreign_issuance_val_amt vào fms_plan_agg,
*                                 cl_ids_business_line_level_1_code vào ids_pc.
*--------------------------------------------------------------------*
*/

-- ============================================================
-- IDS (CTĐC – Công ty đại chúng)
-- ============================================================
WITH ids_base AS (
    SELECT
        pc_securities_offering_id,
        pc_securities_offering_code                         AS offering_code,
        src_stm_code,
        pc_code,
        COALESCE(certificate_nbr, official_letter_nbr)            AS certificate_nbr,
        COALESCE(certificate_dt, official_letter_dt)              AS certificate_dt,
        administrative_procedure_code
    FROM {{ ref('atm_pc_securities_offering') }}_hstr
    WHERE ds_snpst_dt              = to_date('2026-11-11', 'yyyy-MM-dd')
        AND src_stm_code             = 'IDS_SECURITIES_OFFERING'
        AND administrative_status_code = '022'
        AND approval_status_code       = 'APPROVED'
        and deleted_ind                = 0
        AND COALESCE(certificate_dt, official_letter_dt) IS NOT NULL
        -- AND COALESCE(certificate_dt, official_letter_dt)
        --     <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

ids_pc AS (
    SELECT
        pc_code,
        equity_ticker_symbol,
        cl_ids_business_line_level_1_code
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-09-02', 'yyyy-MM-dd')
    --  ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')  -- [DAILY]
),

ids_ip AS (
    SELECT
        ip_code,
        identification_nbr   AS business_reg_no
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt              = to_date('2026-11-05', 'yyyy-MM-dd')
    --  ds_snpst_dt              = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')  -- [DAILY]
        AND src_stm_code             = 'IDS_COMPANY_PROFILES'
        AND identification_tp_code   = 'ESTABLISHMENT_OPERATION_LICENSE'
),

ids_plan_agg AS (
    SELECT
        pc_securities_offering_id,
        security_tp_code,
        offering_method_code,
        security_nm,
        par_val,
        offering_price,
        SUM(total_registered_quantity_snpst)                      AS plan_qty,
        SUM(
            CASE WHEN COALESCE(total_expected_amt_snpst, 0) = 0
                THEN (CASE WHEN COALESCE(offering_price, 0) = 0
                           THEN par_val
                           ELSE offering_price
                      END) * total_registered_quantity_snpst
                ELSE total_expected_amt_snpst
            END
        )                                                         AS plan_amt,
        MAX(bond_term_val)                                        AS bond_term_val,
        MAX(interest_rate)                                        AS interest_rate
    FROM {{ ref('atm_pc_securities_offering_plan') }}_hstr
    WHERE ds_snpst_dt  = to_date('2026-11-11', 'yyyy-MM-dd')
        AND src_stm_code = 'IDS_SECURITIES_OFFERING_PLAN'
        AND deleted_ind = 0
    GROUP BY
        pc_securities_offering_id,
        security_tp_code,
        offering_method_code,
        security_nm,
        par_val,
        offering_price
),

ids_result_agg AS (
    SELECT
        pc_securities_offering_id,
        offering_method_code_snpst               AS offering_method_code,
        result_rpt_dt,
        offering_end_dt,
        SUM(total_successful_quantity)           AS result_qty,
        SUM(total_collected_amt)                 AS result_amt_orig,
        SUM(foreign_collected_amt)               AS foreign_collected_amt
    FROM {{ ref('atm_pc_securities_offering_result') }}_hstr
    WHERE ds_snpst_dt          = to_date('2026-11-11', 'yyyy-MM-dd')
        and deleted_ind = 0
    --  ds_snpst_dt          = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')  -- [DAILY]
        AND src_stm_code         = 'IDS_SECURITIES_OFFERING_RESULT'
        AND approval_status_code = 'APPROVED'
    GROUP BY
        pc_securities_offering_id,
        offering_method_code_snpst,
        result_rpt_dt,
        offering_end_dt
),

-- ============================================================
-- SCMS (CTCK – Công ty chứng khoán)
-- ============================================================
scms_base AS (
    SELECT
        sc_disclosure_securities_offering_id,
        sc_disclosure_securities_offering_code                   AS offering_code,
        src_stm_code,
        sc_code,
        document_nbr                                             AS certificate_nbr,
        COALESCE(document_dt, CAST(src_record_insert_tms AS date)) AS certificate_dt,
        item_category_code,
        offering_price_amt,
        maturity_years,
        result_rpt_dt,
        offering_end_dt
    FROM {{ ref('atm_sc_disclosure_securities_offering') }}
    WHERE src_stm_code = 'SCMS_DISCLOSURE_SECURITIES_OFFERING'
        AND COALESCE(document_dt, CAST(src_record_insert_tms AS date)) IS NOT NULL
        AND ds_rcrd_st = 'ACTIVE'
        -- AND COALESCE(document_dt, CAST(src_record_insert_tms AS date))
        --     <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

scms_item_agg AS (
    SELECT
        sc_disclosure_securities_offering_id,
        offering_method,
        SUM(plan_quantity)                                    AS plan_qty,
        SUM(plan_val_at_par_amt)                              AS plan_amt,
        SUM(actual_quantity)                                     AS result_qty,
        SUM(actual_val_amt)                                      AS result_amt,
        MAX(CASE WHEN actual_quantity IS NOT NULL
                   OR actual_val_amt  IS NOT NULL THEN 1 ELSE 0
            END)                                                 AS has_actual
    FROM atomic.uat_atm.sc_disclosure_securities_offering_item
    WHERE NULLIF(TRIM(offering_method), '') IS NOT NULL
    GROUP BY
        sc_disclosure_securities_offering_id,
        offering_method
),

-- ============================================================
-- FMS (CTQLQ – Công ty quản lý quỹ)
-- ============================================================
fms_base AS (
    SELECT
        fmc_securities_offering_id,
        fmc_securities_offering_code                             AS offering_code,
        src_stm_code,
        fmc_code,
        approval_document_nbr                                    AS certificate_nbr,
        approval_document_dt                                     AS certificate_dt,
        affair_code                                              AS administrative_procedure_code,
        securities_tp_code,
        securities_nm                                            AS security_nm,
        unit_par_val_amt                                         AS par_val,
        offering_price_amt                                       AS offering_price,
        rpt_result_dt,
        offering_end_dt,
        bond_term_years
    FROM {{ ref('atm_fmc_securities_offering') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-10-09', 'yyyy-MM-dd')
    --  ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')  -- [DAILY]
        AND src_stm_code = 'FMS_OFFERING'
        AND approval_document_dt IS NOT NULL
        --AND approval_document_dt <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

fms_plan_agg AS (
    SELECT
        fmc_securities_offering_id,
        offering_method_code,
        SUM(planned_quantity)           AS plan_qty,
        SUM(planned_val_amt)            AS plan_amt,
        SUM(actual_quantity)            AS result_qty,
        SUM(actual_val_amt)             AS result_amt,
        SUM(foreign_issuance_val_amt)   AS foreign_issuance_val_amt
    FROM {{ ref('atm_fmc_securities_offering_plan') }}_hstr
    WHERE ds_snpst_dt  = to_date('2026-10-09', 'yyyy-MM-dd')
    --  ds_snpst_dt  = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')  -- [DAILY]
        AND src_stm_code = 'FMS_OFFERING_PLAN'
    GROUP BY
        fmc_securities_offering_id,
        offering_method_code
),

-- ============================================================
-- UNION ALL 3 nguồn
-- ============================================================
combined AS (
    -- IDS branch
    SELECT
        b.src_stm_code,
        b.offering_code,
        COALESCE(p.offering_method_code, '')                     AS offering_method_code,
        COALESCE(p.security_nm, '')                              AS security_nm_key,
        b.certificate_dt,
        CAST('CTDC'                                              AS string)        AS issuer_tp_code,
        CAST(b.pc_code                                           AS string)        AS issuer_code,
        CAST(pc.equity_ticker_symbol                             AS string)        AS equity_ticker_symbol,
        CAST(b.offering_code                                     AS string)        AS offering_code_col,
        CAST(b.certificate_nbr                                   AS string)        AS certificate_nbr,
        CAST(concat_ws('|',
            'CTDC',
            ip.business_reg_no,
            COALESCE(b.certificate_nbr, '0'),
            CAST(b.certificate_dt AS string)
        )                                                        AS string)        AS offering_round_key,
        CAST(b.administrative_procedure_code                     AS string)        AS administrative_procedure_code,
        CAST(p.security_tp_code                                  AS string)        AS security_tp_code,
        CAST(p.security_nm                                       AS string)        AS security_nm,
        CAST(p.par_val                                           AS decimal(23,2)) AS par_val,
        CAST(p.offering_price                                    AS decimal(23,2)) AS offering_price,
        CAST(p.plan_qty                                          AS bigint)        AS plan_qty,
        CAST(p.plan_amt                                          AS decimal(23,2)) AS plan_amt,
        CAST(r.result_qty                                        AS bigint)        AS result_qty,
        CAST(r.result_amt_orig                                   AS decimal(23,2)) AS result_amt,
        CAST(r.result_rpt_dt                                     AS date)          AS result_rpt_dt,
        CAST(r.offering_end_dt                                   AS date)          AS offering_end_dt,
        CAST(CASE
            WHEN TRIM(p.offering_method_code) IN ('1','2','3','13') THEN 'PUBLIC'
            WHEN TRIM(p.offering_method_code) = '5'               THEN 'PRIVATE'
            WHEN TRIM(p.offering_method_code) = '6'               THEN 'SWAP'
            WHEN TRIM(p.offering_method_code) = '7'               THEN 'DIVIDEND'
            WHEN TRIM(p.offering_method_code) = '8'               THEN 'EQUITY_CAPITAL'
            WHEN TRIM(p.offering_method_code) = '9'
                AND TRIM(p.security_nm) IN (
                    'Phát hành cho người lao động (ESOP)',
                    'Phát hành thưởng cho người lao động'
                )                                                  THEN 'ESOP'
            WHEN TRIM(p.offering_method_code) = '10'              THEN 'ESOP'
            WHEN TRIM(p.offering_method_code) IN ('11','14')      THEN 'INTERNATIONAL'
            WHEN TRIM(p.offering_method_code) IN ('4','12','15')  THEN 'OTHER'
            ELSE NULL
        END AS string)                                                             AS offering_method_group_code,
        CAST(CASE
            WHEN TRIM(p.offering_method_code) IN ('1','2','3','5','7','8','11','12','13','14','15') THEN 1
            WHEN TRIM(p.offering_method_code) = '9'
                AND TRIM(p.security_nm) = 'Phát hành cho người lao động (ESOP)'   THEN 1
            WHEN TRIM(p.offering_method_code) IN ('4','6','10')
                OR  (TRIM(p.offering_method_code) = '9'
                    AND TRIM(p.security_nm) = 'Phát hành thưởng cho người lao động') THEN 0
            ELSE NULL
        END AS int)                                                                AS raising_capital_ind,
        CAST(CASE WHEN r.result_qty IS NOT NULL THEN 1 ELSE 0 END AS int)         AS has_result_ind,
        CAST(TRY_CAST(p.bond_term_val AS decimal(10,4)) AS decimal(10,4))         AS bond_term_years,
        CAST(p.interest_rate                             AS decimal(5,2))          AS issue_interest_rate,
        CAST(pc.cl_ids_business_line_level_1_code               AS string)               AS industry_code,
        CAST(r.foreign_collected_amt                     AS decimal(23,2))        AS foreign_result_val_amt,
        CAST(CASE
            WHEN COALESCE(r.result_amt_orig, 0) = 0
            THEN (CASE WHEN COALESCE(p.offering_price, 0) = 0
                       THEN p.par_val
                       ELSE p.offering_price
                  END) * r.result_qty
            ELSE r.result_amt_orig
        END AS decimal(23,2))                                                      AS result_val_amt
    FROM ids_base b
    LEFT JOIN ids_pc pc
        ON  pc.pc_code = b.pc_code
    LEFT JOIN ids_ip ip
        ON  ip.ip_code = b.pc_code
    JOIN ids_plan_agg p
        ON  p.pc_securities_offering_id = b.pc_securities_offering_id
    LEFT JOIN ids_result_agg r
        ON  r.pc_securities_offering_id = b.pc_securities_offering_id
        AND r.offering_method_code       = p.offering_method_code

    UNION ALL

    -- FMS branch
    SELECT
        b.src_stm_code,
        b.offering_code,
        COALESCE(p.offering_method_code, '')                     AS offering_method_code,
        COALESCE(b.security_nm, '')                              AS security_nm_key,
        b.certificate_dt,
        CAST('CTQLQ'                                             AS string)        AS issuer_tp_code,
        CAST(b.fmc_code                                          AS string)        AS issuer_code,
        CAST(NULL                                                AS string)        AS equity_ticker_symbol,
        CAST(b.offering_code                                     AS string)        AS offering_code_col,
        CAST(b.certificate_nbr                                   AS string)        AS certificate_nbr,
        CAST(concat_ws('|',
            'CTQLQ',
            b.fmc_code,
            COALESCE(b.certificate_nbr, '0'),
            CAST(b.certificate_dt AS string)
        )                                                        AS string)        AS offering_round_key,
        CAST(b.administrative_procedure_code                     AS string)        AS administrative_procedure_code,
        CAST(b.securities_tp_code                                AS string)        AS security_tp_code,
        CAST(b.security_nm                                       AS string)        AS security_nm,
        CAST(b.par_val                                           AS decimal(23,2)) AS par_val,
        CAST(b.offering_price                                    AS decimal(23,2)) AS offering_price,
        CAST(p.plan_qty                                          AS bigint)        AS plan_qty,
        CAST(p.plan_amt                                          AS decimal(23,2)) AS plan_amt,
        CAST(p.result_qty                                        AS bigint)        AS result_qty,
        CAST(p.result_amt                                        AS decimal(23,2)) AS result_amt,
        CAST(b.rpt_result_dt                                     AS date)          AS result_rpt_dt,
        CAST(b.offering_end_dt                                   AS date)          AS offering_end_dt,
        CAST(CASE
            WHEN p.offering_method_code IN ('01','05') THEN 'PUBLIC'
            WHEN p.offering_method_code = '06'         THEN 'PRIVATE'
            WHEN p.offering_method_code = '07'         THEN 'SWAP'
            WHEN p.offering_method_code = '03'         THEN 'DIVIDEND'
            WHEN p.offering_method_code = '09'         THEN 'EQUITY_CAPITAL'
            WHEN p.offering_method_code IN ('02','04') THEN 'ESOP'
            WHEN p.offering_method_code IN ('08','10') THEN 'OTHER'
            ELSE NULL
        END AS string)                                                             AS offering_method_group_code,
        CAST(CASE
            WHEN p.offering_method_code IN ('01','03','04','05','06','09','10') THEN 1
            WHEN p.offering_method_code IN ('02','07','08')                     THEN 0
            ELSE NULL
        END AS int)                                                                AS raising_capital_ind,
        CAST(CASE WHEN b.rpt_result_dt IS NOT NULL THEN 1 ELSE 0 END AS int)      AS has_result_ind,
        CAST(b.bond_term_years                                   AS decimal(10,4)) AS bond_term_years,
        CAST(NULL                                                AS decimal(5,2))  AS issue_interest_rate,
        CAST('07000'                                             AS string)        AS industry_code,
        CAST(p.foreign_issuance_val_amt                         AS decimal(23,2)) AS foreign_result_val_amt,
        CAST(p.result_amt                                        AS decimal(23,2)) AS result_val_amt
    FROM fms_base b
    LEFT JOIN fms_plan_agg p
        ON  p.fmc_securities_offering_id = b.fmc_securities_offering_id

    UNION ALL

    -- SCMS branch
    SELECT
        b.src_stm_code,
        b.offering_code,
        COALESCE(sci.offering_method, '')                        AS offering_method_code,
        ''                                                       AS security_nm_key,
        b.certificate_dt,
        CAST('CTCK'                                              AS string)        AS issuer_tp_code,
        CAST(b.sc_code                                           AS string)        AS issuer_code,
        CAST(NULL                                                AS string)        AS equity_ticker_symbol,
        CAST(b.offering_code                                     AS string)        AS offering_code_col,
        CAST(b.certificate_nbr                                   AS string)        AS certificate_nbr,
        CAST(concat_ws('|',
            'CTCK',
            b.sc_code,
            COALESCE(b.certificate_nbr, '0'),
            CAST(b.certificate_dt AS string)
        )                                                        AS string)        AS offering_round_key,
        CAST(NULL                                                AS string)        AS administrative_procedure_code,
        CAST(b.item_category_code                                AS string)        AS security_tp_code,
        CAST(NULL                                                AS string)        AS security_nm,
        CAST(NULL                                                AS decimal(23,2)) AS par_val,
        CAST(b.offering_price_amt                                AS decimal(23,2)) AS offering_price,
        CAST(sci.plan_qty                                        AS bigint)        AS plan_qty,
        CAST(sci.plan_amt                                        AS decimal(23,2)) AS plan_amt,
        CAST(sci.result_qty                                      AS bigint)        AS result_qty,
        CAST(sci.result_amt                                      AS decimal(23,2)) AS result_amt,
        CAST(b.result_rpt_dt                                     AS date)          AS result_rpt_dt,
        CAST(b.offering_end_dt                                   AS date)          AS offering_end_dt,
        CAST(CASE sci.offering_method
            WHEN 'CHAO_BAN_RA_CONG_CHUNG'    THEN 'PUBLIC'
            WHEN 'DAU_GIA'                   THEN 'PUBLIC'
            WHEN 'CHAO_BAN_RIENG_LE'         THEN 'PRIVATE'
            WHEN 'PHAT_HANH_CP_DE_HOAN_DOI'  THEN 'SWAP'
            WHEN 'TRA_CO_TUC_BANG_CP'        THEN 'DIVIDEND'
            WHEN 'CHU_SO_HUU_GOP_VON'        THEN 'EQUITY_CAPITAL'
            WHEN 'CO_PHIEU_THUONG'           THEN 'ESOP'
            WHEN 'PHAT_HANH_CO_THU_TIEN'     THEN 'ESOP'
            WHEN 'PHAT_HANH_TP_QUOC_TE'      THEN 'INTERNATIONAL'
            WHEN 'CO_DONG_LON_CHAO_BAN'      THEN 'OTHER'
            WHEN 'KHAC'                      THEN 'OTHER'
            ELSE NULL
        END AS string)                                                             AS offering_method_group_code,
        CAST(CASE
            WHEN sci.offering_method IN (
                'CHAO_BAN_RA_CONG_CHUNG', 'TRA_CO_TUC_BANG_CP', 'PHAT_HANH_CO_THU_TIEN',
                'DAU_GIA', 'CHAO_BAN_RIENG_LE', 'CHU_SO_HUU_GOP_VON', 'KHAC', 'PHAT_HANH_TP_QUOC_TE'
            ) THEN 1
            WHEN sci.offering_method IN (
                'CO_PHIEU_THUONG', 'PHAT_HANH_CP_DE_HOAN_DOI', 'CO_DONG_LON_CHAO_BAN'
            ) THEN 0
            ELSE NULL
        END AS int)                                                                AS raising_capital_ind,
        CAST(sci.has_actual                                      AS int)           AS has_result_ind,
        CAST(b.maturity_years                                    AS decimal(10,4)) AS bond_term_years,
        CAST(NULL                                                AS decimal(5,2))  AS issue_interest_rate,
        CAST('07000'                                             AS string)        AS industry_code,
        CAST(NULL                                                AS decimal(23,2)) AS foreign_result_val_amt,
        CAST(sci.result_amt                                      AS decimal(23,2)) AS result_val_amt
    FROM scms_base b
    INNER JOIN scms_item_agg sci
        ON  sci.sc_disclosure_securities_offering_id = b.sc_disclosure_securities_offering_id
)

SELECT
    CAST(
        sha2(concat_ws('|',
            c.src_stm_code,
            c.offering_code,
            c.offering_method_code,
            c.security_nm_key,
            COALESCE(c.security_tp_code,                      ''),
            COALESCE(CAST(c.par_val          AS string),      ''),
            COALESCE(CAST(c.offering_price   AS string),      ''),
            COALESCE(CAST(c.result_rpt_dt    AS string),      ''),
            COALESCE(CAST(c.offering_end_dt  AS string),      '')
        ), 256)
    AS string)                                                      AS securities_offering_event_id,

    CAST(cdr.cdr_dt_dim_id          AS string)                      AS certificate_dt_dim_id,
    c.issuer_tp_code,
    c.issuer_code,
    c.equity_ticker_symbol,
    c.offering_code_col                                             AS offering_code,
    c.certificate_nbr,
    CAST(c.certificate_dt           AS date)                        AS certificate_dt,
    c.offering_round_key,
    c.administrative_procedure_code,
    c.security_tp_code,
    c.security_nm,
    c.offering_method_code,
    c.offering_method_group_code,
    c.raising_capital_ind,
    c.plan_qty,
    c.plan_amt,
    c.result_qty,
    c.result_amt,
    c.result_rpt_dt,
    c.has_result_ind,
    c.bond_term_years,
    c.issue_interest_rate,
    c.industry_code,
    c.foreign_result_val_amt,
    c.result_val_amt,
    CAST(c.src_stm_code             AS string)                      AS src_stm_code

FROM combined c
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cdr
    ON  cdr.cdr_dt = c.certificate_dt
