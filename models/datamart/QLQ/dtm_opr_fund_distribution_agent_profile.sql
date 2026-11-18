/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fund_distribution_agent_profile
* Program name: Dtm Opr Fund Distribution Agent Profile
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		claude (sync)		Đồng bộ LLD commit ccc6d036 (O_QLQ_71): 14 KPI TinhHinhGiaoDichCCQ_06268 so khớp nhãn cột theo phần tử CUỐI của SPLIT(column_label_nm,' >> ') (nhãn thật có tiền tố nhóm cột) (logic-only, schema không đổi)
* 2026-11-03		claude (sync)		Đồng bộ LLD commit f2628ecf (O_QLQ_72): bỏ 14 cột rpt (trading/holding account, fund certificate, issued/redeemed — chuyển sang fct_fund_management_rpt_cell_val), bỏ CTE fmr_value/fmr_submission/rpt_cell_val/rpt_kpi_candidate/rpt_kpi;
*                                       thêm distribution_cert_dt = MIN(identification_issue_dt) ESTABLISHMENT_OPERATION_LICENSE (schema-changing)
*/

WITH securities_distribution_agent AS (
    SELECT
        securities_distribution_agent_id,
        securities_distribution_agent_code,
        securities_distribution_agent_full_nm,
        securities_distribution_agent_short_nm,
        termination_dt,
        src_stm_code
    FROM {{ ref('dtm_securities_distribution_agent_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_DISTRIBUTOR_AGENT'
),

operation_license AS (
    SELECT
        ip_id,
        MIN(identification_issue_dt) AS distribution_cert_dt
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_DISTRIBUTOR_AGENT'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
        AND identification_issue_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    GROUP BY ip_id
),

business_license AS (
    SELECT
        ip_id,
        identification_nbr,
        identification_issue_dt
    FROM (
        SELECT
            ip_id,
            identification_nbr,
            identification_issue_dt,
            ROW_NUMBER() OVER (PARTITION BY ip_id 
                               ORDER BY identification_issue_dt DESC, identification_nbr) 
            AS rn
        FROM {{ ref('atm_ip_alternative_identification') }}_hstr
        WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND ds_rcrd_st = 'ACTIVE'
            AND src_stm_code = 'FMS_DISTRIBUTOR_AGENT'
            AND identification_tp_code = 'BUSINESS_LICENSE'
    ) t
    WHERE rn = 1
),

head_office AS (
    SELECT
        ip_id,
        adr_val
    FROM (
        SELECT
            ip_id,
            adr_val,
            ROW_NUMBER() OVER (PARTITION BY ip_id 
                               ORDER BY adr_val) 
            AS rn
        FROM {{ ref('atm_ip_postal_address') }}_hstr
        WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND ds_rcrd_st = 'ACTIVE'
            AND src_stm_code = 'FMS_DISTRIBUTOR_AGENT'
            AND adr_tp_code = 'HEAD_OFFICE'
    ) t
    WHERE rn = 1
),

fund_distribution_agent_x_investment_fund_rltnp AS (
    SELECT
        fund_distribution_agent_code,
        investment_fund_id,
        investment_fund_code
    FROM {{ ref('atm_fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUD_AG_AGT'
),

investment_fund AS (
    SELECT
        investment_fund_id
    FROM {{ ref('dtm_investment_fund_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

distributing_fund_agg AS (
    SELECT
        rltnp.fund_distribution_agent_code                                      AS securities_distribution_agent_code,
        COUNT(DISTINCT rltnp.investment_fund_code)                              AS distributing_fund_count
    FROM fund_distribution_agent_x_investment_fund_rltnp rltnp
    INNER JOIN investment_fund
        ON investment_fund.investment_fund_id = rltnp.investment_fund_id
    GROUP BY rltnp.fund_distribution_agent_code
)

SELECT
    CAST(sda.securities_distribution_agent_code AS string)                                    AS securities_distribution_agent_code,
    CAST(sda.securities_distribution_agent_full_nm AS string)                                 AS securities_distribution_agent_full_nm,
    CAST(business_license.identification_nbr AS string)                                       AS license_nbr,
    CAST(business_license.identification_issue_dt AS date)                                    AS license_dt,
    CAST(head_office.adr_val AS string)                                                       AS address,
    CAST(CASE WHEN sda.termination_dt IS NULL THEN 1 ELSE 0 END AS int)                       AS active_status_flag,
    CAST(sda.termination_dt AS date)                                                          AS termination_dt,
    CAST(operation_license.distribution_cert_dt AS date)                                      AS distribution_cert_dt,
    CAST(COALESCE(distributing_fund_agg.distributing_fund_count, 0) AS int)                   AS distributing_fund_count,
    CAST(sda.src_stm_code AS string)                                                          AS src_stm_code
FROM securities_distribution_agent sda
INNER JOIN operation_license
    ON operation_license.ip_id = sda.securities_distribution_agent_id
LEFT JOIN business_license
    ON business_license.ip_id = sda.securities_distribution_agent_id
LEFT JOIN head_office
    ON head_office.ip_id = sda.securities_distribution_agent_id
LEFT JOIN distributing_fund_agg
    ON distributing_fund_agg.securities_distribution_agent_code = sda.securities_distribution_agent_code
