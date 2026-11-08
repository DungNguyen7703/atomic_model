/*
*--------------------------------------------------------------------*
* Program code: stg_tms_investor_account
* Program name: Staging TMS.INVESTOR_ACCOUNT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                              AS id
    , CAST(account_code AS string)                    AS account_code
    , CAST(investor_type AS int)                      AS investor_type
    , CAST(date_of_birth AS timestamp)                AS date_of_birth
    , CAST(legal_representative AS string)            AS legal_representative
    , CAST(permanent_address AS string)               AS permanent_address
    , CAST(margin_account_open_date AS timestamp)     AS margin_account_open_date
    , CAST(margin_service_enabled AS string)          AS margin_service_enabled
    , CAST(advance_payment_service_enabled AS string) AS advance_payment_service_enabled
    , CAST(account_authorization_enabled AS string)   AS account_authorization_enabled
    , CAST(authorized_person_name AS string)          AS authorized_person_name
    , CAST(authorization_date AS timestamp)           AS authorization_date
    , CAST(approval_status AS int)                    AS approval_status
    , CAST(account_status AS int)                     AS account_status
    , CAST(domestic_foreign_flag AS int)              AS domestic_foreign_flag
    , CAST(data_source AS string)                     AS data_source
    , CAST(created_at AS timestamp)                   AS created_at
    , CAST(updated_at AS timestamp)                   AS updated_at
    , CAST(created_by_id AS string)                   AS created_by_id
    , CAST(updated_by_id AS string)                   AS updated_by_id
    , CAST(created_by_name AS string)                 AS created_by_name
    , CAST(updated_by_name AS string)                 AS updated_by_name
    , CAST(version AS int)                            AS version
    , CAST(deleted AS int)                            AS deleted
FROM {{ source('source_tms', 'raw_investor_account') }}