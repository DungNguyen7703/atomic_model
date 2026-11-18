/*
*--------------------------------------------------------------------*
* Program code: atm_sp_related_party
* Program name: Atomic Securities Practitioner Related Party
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pr_re AS (
    SELECT
        id
        , professional_id
        , relationship_type
        , full_name
        , birth_year
        , address
        , occupation
        , workplace
        , identity_id
        , country_id
        , note
    FROM {{ ref('ods_nhnck_professional_relationships') }}
),

coun AS (
    SELECT
        id
        , country_code
    FROM {{ ref('ods_nhnck_countries') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONAL_RELATIONSHIPS', "pr_re.id") }}   AS sp_related_party_id
    , CAST(pr_re.id AS string)                                                            AS sp_related_party_code
    , CAST('NHNCK_PROFESSIONAL_RELATIONSHIPS' AS string)                                  AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "pr_re.professional_id") }} AS sp_id
    , CAST(pr_re.professional_id AS string)                                               AS sp_code
    , CAST(pr_re.relationship_type AS string)                                             AS rltnp_tp_code
    , CAST(pr_re.full_name AS string)                                                     AS related_individual_full_nm
    , CAST(pr_re.birth_year AS int)                                                       AS related_individual_birth_year
    , CAST(pr_re.address AS string)                                                       AS related_individual_adr
    , CAST(pr_re.occupation AS string)                                                    AS related_individual_occupation
    , CAST(pr_re.workplace AS string)                                                     AS related_individual_workplace
    , CAST(pr_re.identity_id AS string)                                                   AS related_individual_identity_nbr
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "coun.country_code") }}            AS country_id
    , CAST(pr_re.country_id AS string)                                                    AS country_code
    , CAST(pr_re.note AS string)                                                          AS note
FROM pr_re
    LEFT JOIN coun ON pr_re.COUNTRY_ID = coun.ID