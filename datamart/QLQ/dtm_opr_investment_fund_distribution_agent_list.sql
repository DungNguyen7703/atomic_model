/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_investment_fund_distribution_agent_list
* Program name: Dtm Opr Investment Fund Distribution Agent List
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-14		claude (sync)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_opr_investment_fund_distribution_agent_list_FMS_FUD_AG_AGT.csv (commit 2f62880d)
*                                       Grain: 1 cặp (investment_fund_code, fund_distribution_agent_code). Driving: atm_fund_distribution_agent_x_
*                                       investment_fund_x_cl_fms_agency_type_relationship (scd2, src FMS_FUD_AG_AGT), lọc loại 'đại lý phân phối'
*                                       EXISTS (LLD) -> LEFT SEMI JOIN; 1 cặp quỹ-đại lý có thể gắn nhiều loại -> SELECT DISTINCT tránh trùng PK
*--------------------------------------------------------------------*
*/

WITH cl_fms_agency_type AS (
    SELECT
        cl_fms_agency_tp_id
    FROM {{ ref('atm_cl_fms_agency_type') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_AGENCY_TYPE'
        AND lower(cl_fms_agency_tp_nm) LIKE '%đại lý phân phối%'
),

fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship AS (
    SELECT DISTINCT
        rltnp.investment_fund_code,
        rltnp.fund_distribution_agent_code,
        CAST(rltnp.fund_distribution_agent_id AS string) AS fund_distribution_agent_id,
        rltnp.src_stm_code
    FROM {{ ref('atm_fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship') }} rltnp
    LEFT SEMI JOIN cl_fms_agency_type
        ON cl_fms_agency_type.cl_fms_agency_tp_id = rltnp.cl_fms_agency_tp_id
        AND rltnp.ds_rcrd_st = 'ACTIVE'
        AND rltnp.src_stm_code = 'FMS_FUD_AG_AGT'
),

fund_distribution_agent AS (
    SELECT
        fund_distribution_agent_id,
        fund_distribution_agent_full_nm
    FROM {{ ref('dtm_fund_distribution_agent_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_AGENCIES'
)

SELECT
    CAST(rltnp.investment_fund_code AS string)                                                AS investment_fund_code,
    CAST(rltnp.fund_distribution_agent_code AS string)                                        AS fund_distribution_agent_code,
    CAST(fund_distribution_agent.fund_distribution_agent_full_nm AS string)                   AS fund_distribution_agent_full_nm,
    CAST(rltnp.src_stm_code AS string)                                                        AS src_stm_code
FROM fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship rltnp
LEFT JOIN fund_distribution_agent
    ON fund_distribution_agent.fund_distribution_agent_id = rltnp.fund_distribution_agent_id
