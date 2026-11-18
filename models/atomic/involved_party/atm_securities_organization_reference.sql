/*
*--------------------------------------------------------------------*
* Program code: atm_securities_organization_reference
* Program name: Atomic Securities Organization Reference
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH org AS (
    SELECT
        id
        , organization_code
        , organization_name
        , english_name
        , abbreviation
        , organization_type_id
        , level_
        , parent_id
        , linked_id
        , sync_id
        , representative
        , license_number
        , license_issuer
        , license_date
        , charter_capital
        , description
        , sort_order
        , last_sync_date
        , sync_status
    FROM {{ ref('ods_nhnck_organizations') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_ORGANIZATIONS', "org.id") }}          AS securities_organization_reference_id
    , CAST(org.id AS string)                                                      AS securities_organization_reference_code
    , CAST('NHNCK_ORGANIZATIONS' AS string)                                       AS src_stm_code
    , CAST(org.organization_code AS string)                                       AS organization_code
    , CAST(org.organization_name AS string)                                       AS securities_organization_reference_nm
    , CAST(org.english_name AS string)                                            AS securities_organization_reference_english_nm
    , CAST(org.abbreviation AS string)                                            AS securities_organization_reference_short_nm
    , CAST(org.organization_type_id AS string)                                    AS organization_tp_code
    , CAST(org.level_ AS string)                                                  AS organization_level_code
    , {{ generate_surrogate_key_bigint('NHNCK_ORGANIZATIONS', "org.parent_id") }} AS parent_securities_organization_reference_id
    , CAST(org.parent_id AS string)                                               AS parent_securities_organization_reference_code
    , CAST(org.linked_id AS string)                                               AS external_stm_linked_id
    , CAST(org.sync_id AS string)                                                 AS external_stm_sync_id
    , CAST(org.representative AS string)                                          AS legal_representative_nm
    , CAST(org.license_number AS string)                                          AS license_nbr
    , CAST(org.license_issuer AS string)                                          AS license_issuer_nm
    , CAST(org.license_date AS date)                                              AS license_dt
    , CAST(org.charter_capital AS decimal(23,2))                                  AS charter_capital_amt
    , CAST(org.description AS string)                                             AS description
    , CAST(org.sort_order AS int)                                                 AS sort_order
    , CAST(org.last_sync_date AS date)                                            AS last_sync_dt
    , CAST(org.sync_status AS string)                                             AS sync_status_code
FROM org