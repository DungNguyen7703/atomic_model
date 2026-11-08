/*
*--------------------------------------------------------------------*
* Program code: atm_fmc_securities_offering_plan
* Program name: Atomic Fund Management Company Securities Offering Plan
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-21		tuan.nguyenvanb		[LLD lld_FMS_OFFERING_PLAN.yaml (approved)] Atomic moi. scd4a, unique_key fmc_securities_offering_plan_id.
*--------------------------------------------------------------------*
*/

WITH opl AS (
    SELECT
        id
        , offering_id
        , target_audience
        , method_code
        , quantity_cb
        , price_cb
        , value_cb
        , people_count
        , audience_description
        , swap_purpose
        , actual_quantity_cb
        , actual_price_cb
        , actual_value_cb
        , actual_people_count
        , actual_audience_description
        , actual_swap_purpose
        , foreign_investor_count
        , issuance_value_foreign
    FROM {{ ref('ods_fms_offering_plan') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_OFFERING_PLAN', "opl.id") }}               AS fmc_securities_offering_plan_id
    , CAST(opl.id AS string)                                                         AS fmc_securities_offering_plan_code
    , CAST('FMS_OFFERING_PLAN' AS string)                                            AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_OFFERING', "opl.offering_id") }}         AS fmc_securities_offering_id
    , CAST(opl.offering_id AS string)                                                AS fmc_securities_offering_code
    , CAST(opl.target_audience AS string)                                            AS target_audience_description
    , CAST(opl.method_code AS string)                                                AS offering_method_code
    , CAST(opl.quantity_cb AS bigint)                                                AS planned_quantity
    , CAST(opl.price_cb AS decimal(23,2))                                            AS planned_price_amt
    , CAST(opl.value_cb AS decimal(23,2))                                            AS planned_val_amt
    , CAST(opl.people_count AS int)                                                  AS planned_participant_count
    , CAST(opl.audience_description AS string)                                       AS audience_description
    , CAST(opl.swap_purpose AS string)                                               AS swap_purpose_description
    , CAST(opl.actual_quantity_cb AS bigint)                                         AS actual_quantity
    , CAST(opl.actual_price_cb AS decimal(23,2))                                     AS actual_price_amt
    , CAST(opl.actual_value_cb AS decimal(23,2))                                     AS actual_val_amt
    , CAST(opl.actual_people_count AS int)                                           AS actual_participant_count
    , CAST(opl.actual_audience_description AS string)                                AS actual_audience_description
    , CAST(opl.actual_swap_purpose AS string)                                        AS actual_swap_purpose_description
    , CAST(opl.foreign_investor_count AS int)                                        AS foreign_investor_participant_count
    , CAST(opl.issuance_value_foreign AS decimal(23,2))                              AS foreign_issuance_val_amt
FROM opl
