/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fund_management_company_profile
* Program name: Dtm Opr Fund Management Company Profile
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		claude (sync)		Đồng bộ LLD commit ed71223d (O_QLQ_64/65): thêm fmc_id (khóa nối fct_fund_management_rpt_cell_val.fmc_id),
*                                       charter_capital_amt = dim.charter_capital_amt (SECURITIES.CAPITAL),
*                                       establishment_license_dt = MIN(identification_issue_dt) ESTABLISHMENT_OPERATION_LICENSE của CTQLQ
*                                       (atm_ip_alternative_identification_hstr, src FMS_SECURITIES); subquery tương quan LLD -> CTE GROUP BY ip_id
*                                       (schema-changing, cần DROP/CREATE lại bảng scd4a + _hstr)
* 2026-11-02		claude (sync)		Đối chiếu LLD commit 1fde1c17 (O_QLQ_67) + 4c3d0a67 (O_QLQ_68): charter_capital_amt, establishment_license_dt
*                                       đã bị gỡ khỏi LLD (K_QLQ_26 đọc fact báo cáo BCĐKT mã 411) — SELECT hiện tại không còn 2 cột này,
*                                       khớp LLD HEAD; ghi chú 2026-11-02 ở trên về 2 cột đó không còn hiệu lực
* 2026-11-11		claude (sync)		Đồng bộ LLD commit 56eb71c6 (O_QLQ_88, SCHEMA-CHANGING): gỡ rating_class_code + total_score_amt khỏi Profile
*                                       (chuyển sang dtm_fct_fund_management_company_rating_snpst, nối qua fmc_id); bỏ 3 CTE
*                                       member_rating_period / atm_member_rating / member_rating và LEFT JOIN member_rating
*--------------------------------------------------------------------*
*/

WITH fund_management_company AS (
    SELECT
        fmc_id,
        fmc_code,
        fmc_full_nm,
        fmc_short_nm,
        operation_status_code,
        src_stm_code
    FROM {{ ref('dtm_fund_management_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SECURITIES'
        AND LAST_DAY(actual_operation_commencement_dt) <= LAST_DAY(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
),

fmc_employee AS (
    SELECT
        fmc_id,
        fmc_employee_full_nm
    FROM {{ ref('atm_fmc_employee') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_TL_PROFILES'
        AND held_share_percentage = 1
),

legal_representative AS (
    SELECT
        fmc_id,
        array_join(sort_array(collect_list(fmc_employee_full_nm)), '; ') AS legal_representative_nm
    FROM fmc_employee
    GROUP BY fmc_id
),

cl_fms_status AS (
    SELECT
        cl_fms_status_code,
        cl_fms_status_nm
    FROM {{ ref('atm_cl_fms_status') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_STATUS'
),

investment_fund AS (
    SELECT
        fmc_id
    FROM {{ ref('dtm_investment_fund_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

fund_agg AS (
    SELECT
        fmc_id,
        COUNT(*) AS fund_count
    FROM investment_fund
    GROUP BY fmc_id
)

SELECT
    CAST(fmc.fmc_code AS string)                                            AS fmc_code,
    CAST(fmc.fmc_id AS string)                                              AS fmc_id,
    CAST(fmc.fmc_full_nm AS string)                                         AS fmc_full_nm,
    CAST(fmc.fmc_short_nm AS string)                                        AS fmc_short_nm,
    CAST(cl_fms_status.cl_fms_status_nm AS string)                          AS operation_status_nm,
    CAST(legal_representative.legal_representative_nm AS string)            AS legal_representative_nm,
    CAST(COALESCE(fund_agg.fund_count, 0) AS int)                           AS fund_count,
    CAST(fmc.src_stm_code AS string)                                        AS src_stm_code
FROM fund_management_company fmc
LEFT JOIN legal_representative
    ON legal_representative.fmc_id = fmc.fmc_id
LEFT JOIN cl_fms_status
    ON cl_fms_status.cl_fms_status_code = fmc.operation_status_code
LEFT JOIN fund_agg
    ON fund_agg.fmc_id = fmc.fmc_id
