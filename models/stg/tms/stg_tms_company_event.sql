/*
*--------------------------------------------------------------------*
* Program code: stg_tms_company_event
* Program name: Staging TMS.COMPANY_EVENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                     AS id
    , CAST(company_name AS string)           AS company_name
    , CAST(stock_code AS string)             AS stock_code
    , CAST(event_type AS string)             AS event_type
    , CAST(event AS string)                  AS event
    , CAST(event_date AS timestamp)          AS event_date
    , CAST(approval_status AS int)           AS approval_status
    , CAST(reference_price AS decimal(18,2)) AS reference_price
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(updated_at AS timestamp)          AS updated_at
    , CAST(created_by_id AS string)          AS created_by_id
    , CAST(updated_by_id AS string)          AS updated_by_id
    , CAST(created_by_name AS string)        AS created_by_name
    , CAST(updated_by_name AS string)        AS updated_by_name
    , CAST(deleted AS int)                   AS deleted
FROM {{ source('source_tms', 'raw_company_event') }}