/*
*--------------------------------------------------------------------*
* Program code: atm_securities_distribution_agent
* Program name: Atomic Securities Distribution Agent
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khoi tao theo LLD Atomic FMS UAT 20261006 (lld_FMS_DISTRIBUTOR_AGENT.yaml)
*--------------------------------------------------------------------*
*/

WITH di_ag AS (
    SELECT
        id
        , agent_type
        , company_type
        , item_name
        , name_en
        , short_name
        , termination_date
    FROM {{ ref('ods_fms_distributor_agent') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_DISTRIBUTOR_AGENT', "di_ag.id") }}     AS securities_distribution_agent_id
    , CAST(di_ag.id AS string)                                                   AS securities_distribution_agent_code
    , CAST('FMS_DISTRIBUTOR_AGENT' AS string)                                    AS src_stm_code
    , CAST(di_ag.agent_type AS string)                                           AS agent_tp_description
    , CAST(di_ag.company_type AS string)                                         AS company_tp_code
    , CAST(di_ag.item_name AS string)                                            AS securities_distribution_agent_full_nm
    , CAST(di_ag.name_en AS string)                                              AS securities_distribution_agent_english_nm
    , CAST(di_ag.short_name AS string)                                           AS securities_distribution_agent_short_nm
    , CAST(di_ag.termination_date AS date)                                       AS termination_dt
FROM di_ag