/*
*--------------------------------------------------------------------*
* Program code: stg_tms_analysis_mm_stock_account
* Program name: Staging TMS.ANALYSIS_MM_STOCK_ACCOUNT
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
    , CAST(stock_detail_id AS string)              AS stock_detail_id
    , CAST(case_file_id AS string)                 AS case_file_id
    , CAST(workflow_type AS int)                   AS workflow_type
    , CAST(result_type AS int)                     AS result_type
    , CAST(securities_code_id AS string)           AS securities_code_id
    , CAST(securities_code AS string)              AS securities_code
    , CAST(account_code AS string)                 AS account_code
    , CAST(trading_value AS decimal(19,0))         AS trading_value
    , CAST(trading_value_display AS decimal(20,4)) AS trading_value_display
    , CAST(trading_volume AS decimal(19,0))        AS trading_volume
    , CAST(bc01_matched AS int)                    AS bc01_matched
    , CAST(bc02_matched AS int)                    AS bc02_matched
    , CAST(bc03_matched AS int)                    AS bc03_matched
    , CAST(bc04_matched AS int)                    AS bc04_matched
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(updated_at AS timestamp)                AS updated_at
    , CAST(created_by_id AS string)                AS created_by_id
    , CAST(created_by_name AS string)              AS created_by_name
    , CAST(updated_by_id AS string)                AS updated_by_id
    , CAST(updated_by_name AS string)              AS updated_by_name
    , CAST(deleted AS int)                         AS deleted
    , CAST(workflow_id AS string)                  AS workflow_id
FROM {{ source('source_tms', 'raw_analysis_mm_stock_account') }}