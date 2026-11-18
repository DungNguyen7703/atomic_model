/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_investment_fund_profile
* Program name: Dtm Opr Investment Fund Profile
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		claude (sync)		Đồng bộ LLD commit ccc6d036 (O_QLQ_71): net_asset_val_amt so khớp phần tử ĐẦU của SPLIT(column_label_nm,' >> ') LIKE 'Kỳ báo cáo%' (nhãn thật có đuôi số thứ tự) (logic-only, schema không đổi)
* 2026-11-03		claude				year_to_dt_profit_amt: bỏ BCKetQuaHoatDongKinhDoanh (BCTC công ty QLQ, không phải quỹ); lấy 06025 dòng 50 'Năm báo cáo >> Lũy kế...' và 06203 dòng 41 'Năm N >> Số lũy kế'; version 06203 không có cột lũy kế thì cộng dồn 'Kỳ này' các quý (bán niên lấy thẳng) (logic-only, schema không đổi)
* 2026-11-03		claude (sync)		Đồng bộ LLD commit f2628ecf (O_QLQ_72): bỏ net_asset_val_amt + year_to_dt_profit_amt (chuyển sang fct_fund_management_rpt_cell_val); bỏ toàn bộ CTE fmr_value/fmr_submission/rpt_cell_val/profit_period/profit_ytd_derived/kpi_candidate/rpt_kpi (gồm logic cộng dồn lũy kế 06203 sửa tay 2026-11-03) (schema-changing)
*/

WITH establishment_license AS (
    SELECT DISTINCT
        ip_id
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
        AND identification_issue_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

investment_fund AS (
    SELECT
        investment_fund_id,
        investment_fund_code,
        investment_fund_full_nm,
        investment_fund_short_nm,
        fund_tp_code,
        fmc_id,
        custodian_bank_id,
        total_outstanding_unit_quantity,
        src_stm_code
    FROM {{ ref('dtm_investment_fund_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

fund_management_company AS (
    SELECT
        fmc_id,
        fmc_full_nm
    FROM {{ ref('dtm_fund_management_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SECURITIES'
),

custodian_bank AS (
    SELECT
        custodian_bank_id,
        custodian_bank_full_nm
    FROM {{ ref('dtm_custodian_bank_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_BANK_MONI'
),

representative_board_member AS (
    SELECT
        investment_fund_id,
        cl_fms_job_code
    FROM {{ ref('atm_investment_fund_representative_board_member') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_REPRESENT'
),

cl_fms_job AS (
    SELECT
         cl_fms_job_code,
         job_tp_nm
    FROM {{ ref('atm_cl_fms_job') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_JOBS'
),

fmc_employee AS (
    SELECT
        fmc_employee_id
    FROM {{ ref('atm_fmc_employee') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_TL_PROFILES'
),

fmc_employee_x_investment_fund_relationship AS (
    SELECT
        investment_fund_id,
        fmc_employee_id
    FROM {{ ref('atm_fmc_employee_x_investment_fund_relationship') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUND_TL_PRO'
),

board_agg AS (
    SELECT
        rbm.investment_fund_id,
        COUNT(*) AS representative_board_member_count
    FROM representative_board_member rbm
    INNER JOIN cl_fms_job
        ON cl_fms_job.cl_fms_job_code = rbm.cl_fms_job_code
    WHERE LOWER(cl_fms_job.job_tp_nm) = 'ban đại diện'
    GROUP BY rbm.investment_fund_id
),

manager_agg AS (
    SELECT
        rltnp.investment_fund_id,
        COUNT(DISTINCT rltnp.fmc_employee_id) AS manager_count
    FROM fmc_employee_x_investment_fund_relationship rltnp
    INNER JOIN fmc_employee
        ON fmc_employee.fmc_employee_id = rltnp.fmc_employee_id
    GROUP BY rltnp.investment_fund_id
),

cl_fms_agency_type AS (
    SELECT
        cl_fms_agency_tp_id,
        cl_fms_agency_tp_nm
    FROM {{ ref('atm_cl_fms_agency_type') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_AGENCY_TYPE'
),

fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship AS (
    SELECT
        investment_fund_id,
        fund_distribution_agent_id,
        cl_fms_agency_tp_id
    FROM {{ ref('atm_fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUD_AG_AGT'
),

distribution_agent_agg AS (
    SELECT
        CAST(rltnp.investment_fund_id AS string)                                AS investment_fund_id,
        COUNT(DISTINCT rltnp.fund_distribution_agent_id)                        AS distribution_agent_count
    FROM fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship rltnp
    INNER JOIN cl_fms_agency_type
        ON cl_fms_agency_type.cl_fms_agency_tp_id = rltnp.cl_fms_agency_tp_id
    WHERE lower(cl_fms_agency_type.cl_fms_agency_tp_nm) LIKE '%đại lý phân phối%'
    GROUP BY CAST(rltnp.investment_fund_id AS string)
)

SELECT
    CAST(investment_fund.investment_fund_code AS string)                                      AS investment_fund_code,
    CAST(investment_fund.investment_fund_full_nm AS string)                                   AS investment_fund_full_nm,
    CAST(investment_fund.investment_fund_short_nm AS string)                                  AS investment_fund_short_nm,
    CAST(investment_fund.fund_tp_code AS string)                                              AS fund_tp_code,
    CAST(fund_management_company.fmc_full_nm AS string)                                       AS fmc_full_nm,
    CAST(custodian_bank.custodian_bank_full_nm AS string)                                     AS custodian_bank_full_nm,
    CAST(COALESCE(board_agg.representative_board_member_count, 0) AS int)                     AS representative_board_member_count,
    CAST(COALESCE(manager_agg.manager_count, 0) AS int)                                       AS manager_count,
    CAST(investment_fund.total_outstanding_unit_quantity AS bigint)                           AS outstanding_unit_quantity,
    CAST(COALESCE(distribution_agent_agg.distribution_agent_count, 0) AS int)                 AS distribution_agent_count,
    CAST(investment_fund.src_stm_code AS string)                                              AS src_stm_code
FROM investment_fund
INNER JOIN establishment_license
    ON establishment_license.ip_id = investment_fund.investment_fund_id
LEFT JOIN fund_management_company
    ON fund_management_company.fmc_id = investment_fund.fmc_id
LEFT JOIN custodian_bank
    ON custodian_bank.custodian_bank_id = investment_fund.custodian_bank_id
LEFT JOIN board_agg
    ON board_agg.investment_fund_id = investment_fund.investment_fund_id
LEFT JOIN manager_agg
    ON manager_agg.investment_fund_id = investment_fund.investment_fund_id
LEFT JOIN distribution_agent_agg
    ON distribution_agent_agg.investment_fund_id = investment_fund.investment_fund_id
