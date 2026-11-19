/*
*--------------------------------------------------------------------*
* Program code: atm_transfer_agent
* Program name: Atomic Transfer Agent
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_FMS_TRANSFER_AGENT.yaml (Fundamental). UAT chua co model nay.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , agent_type
        , company_type
        , item_name
        , name_en
        , short_name
        , termination_date
    FROM {{ ref('ods_fms_transfer_agent') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_TRANSFER_AGENT', "src.id") }} AS transfer_agent_id
    , CAST(src.id AS string)                                              AS transfer_agent_code
    , CAST('FMS_TRANSFER_AGENT' AS string)                                AS src_stm_code
    , CAST(src.agent_type AS string)                                      AS agent_tp_description
    , CAST(src.company_type AS int)                                       AS transfer_agent_company_tp_code
    , CAST(src.item_name AS string)                                       AS transfer_agent_full_nm
    , CAST(src.name_en AS string)                                         AS transfer_agent_english_nm
    , CAST(src.short_name AS string)                                      AS transfer_agent_short_nm
    , CAST(src.termination_date AS date)                                  AS termination_dt
FROM src
