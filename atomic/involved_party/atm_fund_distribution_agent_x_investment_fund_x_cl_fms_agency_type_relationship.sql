/*
*--------------------------------------------------------------------*
* Program code: atm_fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship
* Program name: Atomic Fund Distribution Agent X Investment Fund X Classification FMS Agency Type Relationship
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-14		claude				Khởi tạo theo thiết kế dm_atm_fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship-FMS.FUD_AG_AGT.yaml (draft)
*--------------------------------------------------------------------*
*/

WITH fu_ag AS (
    SELECT
        fud_id
        , agen_id
        , ag_ty_id
    FROM {{ ref('ods_fms_fud_ag_agt') }}
)

SELECT
    CAST('FMS_FUD_AG_AGT' AS string)                                     AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_FUNDS', "fud_id") }}         AS investment_fund_id
    , CAST(fud_id AS string)                                             AS investment_fund_code
    , {{ generate_surrogate_key_bigint('FMS_AGENCIES', "agen_id") }}     AS fund_distribution_agent_id
    , CAST(agen_id AS string)                                            AS fund_distribution_agent_code
    , {{ generate_surrogate_key_bigint('FMS_AGENCY_TYPE', "ag_ty_id") }} AS cl_fms_agency_tp_id
    , CAST(ag_ty_id AS string)                                           AS cl_fms_agency_tp_code
FROM fu_ag
