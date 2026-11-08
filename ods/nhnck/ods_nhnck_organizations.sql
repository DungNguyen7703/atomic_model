/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_organizations
* Program name: ODS NHNCK.ORGANIZATIONS
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
    , parent_id
    , organization_type_id
    , linked_id
    , sync_id
    , level_
    , organization_code
    , organization_name
    , english_name
    , abbreviation
    , address
    , fax
    , phone_number
    , mobile_number
    , representative
    , email
    , description
    , license_number
    , license_issuer
    , license_date
    , status
    , sort_order
    , last_sync_date
    , sync_status
    , created_at
    , created_by
    , updated_at
    , updated_by
    , website
    , charter_capital
FROM {{ ref('stg_nhnck_organizations') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')