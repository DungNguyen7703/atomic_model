/*
*--------------------------------------------------------------------*
* Program code: ods_ids_company_share_statistics
* Program name: ODS IDS.COMPANY_SHARE_STATISTICS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , company_profile_id
    , total_issued_share
    , total_outstanding_share
    , total_outstanding_value
    , total_treasury_share
    , lastest_treasury_purchase_qty
    , lastest_treasury_purchase_end_date
    , preferred_share_type
    , total_preferred_share
    , total_preferred_value
    , created_by
    , created_date
    , updated_by
    , updated_date
FROM {{ ref('stg_ids_company_share_statistics') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')