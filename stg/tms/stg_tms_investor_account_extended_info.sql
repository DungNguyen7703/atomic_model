/*
*--------------------------------------------------------------------*
* Program code: stg_tms_investor_account_extended_info
* Program name: Staging TMS.INVESTOR_ACCOUNT_EXTENDED_INFO
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                       AS id
    , CAST(account_code AS string)             AS account_code
    , CAST(legal_representative AS string)     AS legal_representative
    , CAST(phone_number AS string)             AS phone_number
    , CAST(email AS string)                    AS email
    , CAST(bank_account_holder_name AS string) AS bank_account_holder_name
    , CAST(bank_account_number AS string)      AS bank_account_number
    , CAST(bank_account_name AS string)        AS bank_account_name
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(created_by_id AS string)            AS created_by_id
    , CAST(updated_by_id AS string)            AS updated_by_id
    , CAST(created_by_name AS string)          AS created_by_name
    , CAST(updated_by_name AS string)          AS updated_by_name
    , CAST(deleted AS int)                     AS deleted
    , CAST(approval_status AS int)             AS approval_status
FROM {{ source('source_tms', 'raw_investor_account_extended_info') }}