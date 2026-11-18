/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_organizations
* Program name: Staging NHNCK.ORGANIZATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (9 cot); kieu date sang timestamp (3 cot); them cot tax_code.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(parent_id AS bigint)            AS parent_id
    , CAST(organization_type_id AS bigint) AS organization_type_id
    , CAST(linked_id AS bigint)            AS linked_id
    , CAST(sync_id AS string)              AS sync_id
    , CAST(level_ AS string)               AS level_
    , CAST(organization_code AS string)    AS organization_code
    , CAST(organization_name AS string)    AS organization_name
    , CAST(english_name AS string)         AS english_name
    , CAST(abbreviation AS string)         AS abbreviation
    , CAST(address AS string)              AS address
    , CAST(fax AS string)                  AS fax
    , CAST(phone_number AS string)         AS phone_number
    , CAST(mobile_number AS string)        AS mobile_number
    , CAST(representative AS string)       AS representative
    , CAST(email AS string)                AS email
    , CAST(description AS string)          AS description
    , CAST(license_number AS string)       AS license_number
    , CAST(license_issuer AS string)       AS license_issuer
    , CAST(license_date AS date)           AS license_date
    , CAST(status AS bigint)               AS status
    , CAST(sort_order AS bigint)           AS sort_order
    , CAST(last_sync_date AS timestamp)    AS last_sync_date
    , CAST(sync_status AS bigint)          AS sync_status
    , CAST(created_at AS timestamp)        AS created_at
    , CAST(created_by AS bigint)           AS created_by
    , CAST(updated_at AS timestamp)        AS updated_at
    , CAST(updated_by AS bigint)           AS updated_by
    , CAST(website AS string)              AS website
    , CAST(charter_capital AS string)      AS charter_capital
    , CAST(tax_code AS string)             AS tax_code
FROM {{ source('source_nhnck', 'raw_organizations') }}