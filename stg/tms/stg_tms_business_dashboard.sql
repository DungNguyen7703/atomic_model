/*
*--------------------------------------------------------------------*
* Program code: stg_tms_business_dashboard
* Program name: Staging TMS.BUSINESS_DASHBOARD
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(snapshot_time AS timestamp)          AS snapshot_time
    , CAST(pending_company_events_count AS int) AS pending_company_events_count
    , CAST(listed_organizations_count AS int)   AS listed_organizations_count
    , CAST(securities_companies_count AS int)   AS securities_companies_count
    , CAST(fund_management_count AS int)        AS fund_management_count
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(updated_at AS timestamp)             AS updated_at
    , CAST(created_by_id AS string)             AS created_by_id
    , CAST(updated_by_id AS string)             AS updated_by_id
    , CAST(created_by_name AS string)           AS created_by_name
    , CAST(updated_by_name AS string)           AS updated_by_name
    , CAST(deleted AS int)                      AS deleted
FROM {{ source('source_tms', 'raw_business_dashboard') }}