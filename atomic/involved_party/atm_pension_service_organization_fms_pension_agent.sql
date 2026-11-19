/*
*--------------------------------------------------------------------*
* Program code: atm_pension_service_organization_fms_pension_agent
* Program name: Atomic Pension Service Organization
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_FMS_PENSION_AGENT.yaml (Fundamental). UAT chua co model nay.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , company_type
        , item_name
        , eng_name
        , short_name
        , termination_date
    FROM {{ ref('ods_fms_pension_agent') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_PENSION_AGENT', "src.id") }} AS pension_service_organization_id
    , CAST(src.id AS string)                                             AS pension_service_organization_code
    , CAST('FMS_PENSION_AGENT' AS string)                                AS src_stm_code
    , CAST('AGENT' AS string)                                            AS pension_role_tp_code
    , CAST(src.company_type AS string)                                   AS company_tp_code
    , CAST(src.item_name AS string)                                      AS pension_service_organization_full_nm
    , CAST(src.eng_name AS string)                                       AS pension_service_organization_english_nm
    , CAST(src.short_name AS string)                                     AS pension_service_organization_short_nm
    , CAST(src.termination_date AS date)                                 AS termination_dt
FROM src
