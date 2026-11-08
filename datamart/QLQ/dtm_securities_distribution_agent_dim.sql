/*
*--------------------------------------------------------------------*
* Program code: dtm_securities_distribution_agent_dim
* Program name: Dtm Securities Distribution Agent Dim
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_securities_distribution_agent_dim_FMS_DISTRIBUTOR_AGENT.csv
*                                       CHƯA CÓ model atm_securities_distribution_agent trong lakehouse (chỉ có ODS/STG fms_distributor_agent).
*                                       Model này đang enabled: false trong schema_dtm_qlq.yml — bật lại khi Atomic đã có.
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): active_status_flag suy ra từ termination_dt IS NULL
*                                       (Atomic không còn active_status_flag)
*--------------------------------------------------------------------*
*/

WITH securities_distribution_agent AS (
    SELECT
        securities_distribution_agent_code,
        securities_distribution_agent_full_nm,
        securities_distribution_agent_english_nm,
        securities_distribution_agent_short_nm,
        agent_tp_description,
        company_tp_code,
        termination_dt,
        src_stm_code
    FROM {{ ref('atm_securities_distribution_agent') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_DISTRIBUTOR_AGENT'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('FMS_DISTRIBUTOR_AGENT', 'securities_distribution_agent_code') }} AS string) AS securities_distribution_agent_id,
    CAST(securities_distribution_agent_code AS string)       AS securities_distribution_agent_code,
    CAST(securities_distribution_agent_full_nm AS string)    AS securities_distribution_agent_full_nm,
    CAST(securities_distribution_agent_english_nm AS string) AS securities_distribution_agent_english_nm,
    CAST(securities_distribution_agent_short_nm AS string)   AS securities_distribution_agent_short_nm,
    CAST(agent_tp_description AS string)                     AS agent_tp_description,
    CAST(company_tp_code AS string)                          AS company_tp_code,
    CAST(CASE WHEN termination_dt IS NULL 
              THEN 1 ELSE 0 END AS int)                      AS active_status_flag,
    CAST(termination_dt AS date)                             AS termination_dt,
    CAST(src_stm_code AS string)                             AS src_stm_code
FROM securities_distribution_agent
