/*
*--------------------------------------------------------------------*
* Program code: stg_tms_investor_account_dashboard
* Program name: Staging TMS.INVESTOR_ACCOUNT_DASHBOARD
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                          AS id
    , CAST(snapshot_time AS timestamp)            AS snapshot_time
    , CAST(total_accounts AS int)                 AS total_accounts
    , CAST(opened_accounts AS int)                AS opened_accounts
    , CAST(closed_accounts AS int)                AS closed_accounts
    , CAST(violated_accounts AS int)              AS violated_accounts
    , CAST(changed_accounts AS int)               AS changed_accounts
    , CAST(total_account_groups AS int)           AS total_account_groups
    , CAST(total_investors AS int)                AS total_investors
    , CAST(opened_investors AS int)               AS opened_investors
    , CAST(closed_investors AS int)               AS closed_investors
    , CAST(violated_investors AS int)             AS violated_investors
    , CAST(changed_investors AS int)              AS changed_investors
    , CAST(total_investor_groups AS int)          AS total_investor_groups
    , CAST(pending_accounts AS int)               AS pending_accounts
    , CAST(pending_account_groups_new AS int)     AS pending_account_groups_new
    , CAST(pending_account_groups_updated AS int) AS pending_account_groups_updated
    , CAST(pending_account_groups_deleted AS int) AS pending_account_groups_deleted
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(updated_at AS timestamp)               AS updated_at
    , CAST(created_by_id AS string)               AS created_by_id
    , CAST(updated_by_id AS string)               AS updated_by_id
    , CAST(created_by_name AS string)             AS created_by_name
    , CAST(updated_by_name AS string)             AS updated_by_name
    , CAST(deleted AS int)                        AS deleted
FROM {{ source('source_tms', 'raw_investor_account_dashboard') }}