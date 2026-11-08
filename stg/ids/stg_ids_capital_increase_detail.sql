/*
*--------------------------------------------------------------------*
* Program code: stg_ids_capital_increase_detail
* Program name: Staging IDS.CAPITAL_INCREASE_DETAIL
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                       AS id
    , CAST(capital_increase_plan_id AS decimal(19,0)) AS capital_increase_plan_id
    , CAST(offering_method_cd AS string)              AS offering_method_cd
    , CAST(max_offered_qty AS decimal(19,0))          AS max_offered_qty
    , CAST(offering_price AS decimal(20,2))           AS offering_price
    , CAST(price_range_from AS decimal(20,2))         AS price_range_from
    , CAST(price_range_to AS decimal(20,2))           AS price_range_to
    , CAST(total_par_value AS decimal(20,2))          AS total_par_value
    , CAST(capital_use_plan AS string)                AS capital_use_plan
    , CAST(expected_exec_date AS string)              AS expected_exec_date
    , CAST(created_by AS string)                      AS created_by
    , CAST(created_date AS timestamp)                 AS created_date
    , CAST(updated_by AS string)                      AS updated_by
    , CAST(updated_date AS timestamp)                 AS updated_date
FROM {{ source('source_ids', 'raw_capital_increase_detail') }}