/*
*--------------------------------------------------------------------*
* Program code: dtm_fund_distribution_agent_dim
* Program name: Dtm Fund Distribution Agent Dim
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_fund_distribution_agent_dim_FMS_AGENCIES.csv
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): BỎ license_decision_nbr/dt/issuing_place;
*                                       registered_fund_certificate_count → registered_fund_certificate_nbr (đọc nbr_registered_fund_certificate) (schema-changing)
*--------------------------------------------------------------------*
*/

WITH fund_distribution_agent AS (
    SELECT
        fund_distribution_agent_code,
        fund_distribution_agent_full_nm,
        fund_distribution_agent_short_nm,
        fund_distribution_agent_english_nm,
        suspension_dt,
        operation_commencement_dt,
        nbr_registered_fund_certificate,
        src_stm_code
    FROM {{ ref('atm_fund_distribution_agent') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_AGENCIES'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('FMS_AGENCIES', 'fund_distribution_agent_code') }} AS string) AS fund_distribution_agent_id,
    CAST(fund_distribution_agent_code AS string)             AS fund_distribution_agent_code,
    CAST(fund_distribution_agent_full_nm AS string)          AS fund_distribution_agent_full_nm,
    CAST(fund_distribution_agent_short_nm AS string)         AS fund_distribution_agent_short_nm,
    CAST(fund_distribution_agent_english_nm AS string)       AS fund_distribution_agent_english_nm,
    CAST(suspension_dt AS date)                              AS suspension_dt,
    CAST(operation_commencement_dt AS date)                  AS operation_commencement_dt,
    CAST(nbr_registered_fund_certificate AS string)          AS registered_fund_certificate_nbr,
    CAST(src_stm_code AS string)                             AS src_stm_code
FROM fund_distribution_agent
