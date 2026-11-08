/*
*--------------------------------------------------------------------*
* Program code: stg_tms_analysis_mm_stock_window_detail
* Program name: Staging TMS.ANALYSIS_MM_STOCK_WINDOW_DETAIL
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                           AS id
    , CAST(window_id AS string)                    AS window_id
    , CAST(case_file_id AS string)                 AS case_file_id
    , CAST(workflow_type AS int)                   AS workflow_type
    , CAST(result_type AS int)                     AS result_type
    , CAST(securities_code_id AS string)           AS securities_code_id
    , CAST(securities_code AS string)              AS securities_code
    , CAST(stock_code AS string)                   AS stock_code
    , CAST(stock_type AS string)                   AS stock_type
    , CAST(stock_type_display AS string)           AS stock_type_display
    , CAST(trading_value AS decimal(19,0))         AS trading_value
    , CAST(trading_value_display AS decimal(20,4)) AS trading_value_display
    , CAST(basket_weight_percent AS decimal(10,4)) AS basket_weight_percent
    , CAST(impact_value AS decimal(19,0))          AS impact_value
    , CAST(impact_value_display AS decimal(20,4))  AS impact_value_display
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(updated_at AS timestamp)                AS updated_at
    , CAST(created_by_id AS string)                AS created_by_id
    , CAST(created_by_name AS string)              AS created_by_name
    , CAST(updated_by_id AS string)                AS updated_by_id
    , CAST(updated_by_name AS string)              AS updated_by_name
    , CAST(deleted AS int)                         AS deleted
    , CAST(workflow_id AS string)                  AS workflow_id
FROM {{ source('source_tms', 'raw_analysis_mm_stock_window_detail') }}