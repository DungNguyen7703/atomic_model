/*
*--------------------------------------------------------------------*
* Program code: stg_fms_offering_plan
* Program name: Staging FMS.OFFERING_PLAN
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                         AS id
    , HEX(offering_id)                              AS offering_id
    , CAST(sort_order AS bigint)                    AS sort_order
    , CAST(target_audience AS string)               AS target_audience
    , CAST(method_code AS string)                   AS method_code
    , CAST(quantity_cb AS decimal(38,0))            AS quantity_cb
    , CAST(price_cb AS decimal(38,2))               AS price_cb
    , CAST(value_cb AS decimal(38,2))               AS value_cb
    , CAST(people_count AS bigint)                  AS people_count
    , CAST(audience_description AS string)          AS audience_description
    , CAST(swap_purpose AS string)                  AS swap_purpose
    , CAST(actual_quantity_cb AS decimal(38,0))     AS actual_quantity_cb
    , CAST(actual_price_cb AS decimal(38,2))        AS actual_price_cb
    , CAST(actual_value_cb AS decimal(38,2))        AS actual_value_cb
    , CAST(actual_people_count AS bigint)           AS actual_people_count
    , CAST(actual_audience_description AS string)   AS actual_audience_description
    , CAST(actual_swap_purpose AS string)           AS actual_swap_purpose
    , CAST(foreign_investor_count AS bigint)        AS foreign_investor_count
    , CAST(issuance_value_foreign AS decimal(38,2)) AS issuance_value_foreign
FROM {{ source('source_fms', 'raw_offering_plan') }}