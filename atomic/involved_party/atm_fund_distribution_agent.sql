/*
*--------------------------------------------------------------------*
* Program code: atm_fund_distribution_agent
* Program name: Atomic Fund Distribution Agent
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Sync LLD Atomic FMS UAT 20261006 (lld_FMS_AGENCIES.yaml): bo license_decision_* (DECISION* da map sang
*										IP Alt Identification), active_status_flag; content -> note; distribution_staff_list_text -> distribution_staff_list;
*										registered_fund_certificate_count -> nbr_registered_fund_certificate (string)
*--------------------------------------------------------------------*
*/

WITH agen AS (
    SELECT
        id
        , item_name
        , short_name
        , ename
        , content
        , stop_date
        , active_date
        , list_distribution_staff
        , number_reg_fund_cer
    FROM {{ ref('ods_fms_agencies') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_AGENCIES', "agen.id") }} AS fund_distribution_agent_id
    , CAST(agen.id AS string)                                      AS fund_distribution_agent_code
    , CAST('FMS_AGENCIES' AS string)                               AS src_stm_code
    , CAST(agen.item_name AS string)                               AS fund_distribution_agent_full_nm
    , CAST(agen.short_name AS string)                              AS fund_distribution_agent_short_nm
    , CAST(agen.ename AS string)                                   AS fund_distribution_agent_english_nm
    , CAST(agen.content AS string)                                 AS note
    , CAST(agen.stop_date AS date)                                 AS suspension_dt
    , CAST(agen.active_date AS date)                               AS operation_commencement_dt
    , CAST(agen.list_distribution_staff AS string)                 AS distribution_staff_list
    , CAST(agen.number_reg_fund_cer AS string)                     AS nbr_registered_fund_certificate
FROM agen