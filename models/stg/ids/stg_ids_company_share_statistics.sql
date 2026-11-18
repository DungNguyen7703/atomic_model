/*
*--------------------------------------------------------------------*
* Program code: stg_ids_company_share_statistics
* Program name: Staging IDS.COMPANY_SHARE_STATISTICS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                                    AS id
    , CAST(company_profile_id AS int)                  AS company_profile_id
    , CAST(total_issued_share AS int)                  AS total_issued_share
    , CAST(total_outstanding_share AS int)             AS total_outstanding_share
    , CAST(total_outstanding_value AS int)             AS total_outstanding_value
    , CAST(total_treasury_share AS int)                AS total_treasury_share
    , CAST(lastest_treasury_purchase_qty AS int)       AS lastest_treasury_purchase_qty
    , CAST(lastest_treasury_purchase_end_date AS date) AS lastest_treasury_purchase_end_date
    , CAST(preferred_share_type AS string)             AS preferred_share_type
    , CAST(total_preferred_share AS int)               AS total_preferred_share
    , CAST(total_preferred_value AS int)               AS total_preferred_value
    , CAST(created_by AS string)                       AS created_by
    , CAST(created_date AS date)                       AS created_date
    , CAST(updated_by AS string)                       AS updated_by
    , CAST(updated_date AS date)                       AS updated_date
FROM {{ source('source_ids', 'raw_company_share_statistics') }}