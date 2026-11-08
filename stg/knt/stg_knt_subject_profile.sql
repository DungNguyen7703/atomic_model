/*
*--------------------------------------------------------------------*
* Program code: stg_knt_subject_profile
* Program name: Staging KNT.SUBJECT_PROFILE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(profile_id AS string)              AS profile_id
    , CAST(subject_type AS int)               AS subject_type
    , CAST(subject_name AS string)            AS subject_name
    , CAST(short_name AS string)              AS short_name
    , CAST(official_letter_id AS string)      AS official_letter_id
    , CAST(business_license_number AS string) AS business_license_number
    , CAST(country_id AS string)              AS country_id
    , CAST(website AS string)                 AS website
    , CAST(email AS string)                   AS email
    , CAST(phone AS string)                   AS phone
    , CAST(fax AS string)                     AS fax
    , CAST(address AS string)                 AS address
    , CAST(note AS string)                    AS note
    , CAST(sort_order AS int)                 AS sort_order
    , CAST(date_of_birth AS date)             AS date_of_birth
    , CAST(gender AS int)                     AS gender
    , CAST(id_card_number AS string)          AS id_card_number
    , CAST(created_by AS string)              AS created_by
    , CAST(created_at AS date)                AS created_at
    , CAST(subject_type_catalog_id AS string) AS subject_type_catalog_id
    , CAST(securities_code AS string)         AS securities_code
    , CAST(org_representative_name AS string) AS org_representative_name
    , CAST(full_search AS string)             AS full_search
    , CAST(account_number AS string)          AS account_number
    , CAST(account_opening_place AS string)   AS account_opening_place
    , CAST(decision_id AS string)             AS decision_id
    , CAST(market AS int)                     AS market
FROM {{ source('source_knt', 'raw_subject_profile') }}