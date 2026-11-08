/*
*--------------------------------------------------------------------*
* Program code: stg_tms_transaction_review_investor
* Program name: Staging TMS.TRANSACTION_REVIEW_INVESTOR
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                    AS id
    , CAST(transaction_review_id AS string) AS transaction_review_id
    , CAST(investor_id AS string)           AS investor_id
    , CAST(identity_number AS string)       AS identity_number
    , CAST(investor_data AS string)         AS investor_data
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(updated_at AS timestamp)         AS updated_at
    , CAST(created_by_id AS string)         AS created_by_id
    , CAST(updated_by_id AS string)         AS updated_by_id
    , CAST(created_by_name AS string)       AS created_by_name
    , CAST(updated_by_name AS string)       AS updated_by_name
    , CAST(deleted AS int)                  AS deleted
FROM {{ source('source_tms', 'raw_transaction_review_investor') }}