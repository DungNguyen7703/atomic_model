/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_practitioner_related_party_profile
* Program name: Dtm Opr Practitioner Related Party Profile
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH related_party AS (
    SELECT
        sp_code,
        sp_related_party_code,
        related_individual_full_nm,
        rltnp_tp_code,
        related_individual_occupation,
        related_individual_workplace,
        related_individual_identity_nbr,
        related_individual_adr,
        src_stm_code,
        country_id
    FROM {{ ref('atm_sp_related_party') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_PROFESSIONAL_RELATIONSHIPS'
),

relationship_type_lookup AS (
    SELECT
        cl_nm,
        cl_code
    FROM {{ source('source_atm', 'raw_classification_value') }}
    WHERE schema_code = 'RELATIONSHIP_TYPE'
),

geographic_area AS (
    SELECT
        geographic_area_code,
        geographic_area_nm,
        geographic_area_id
    FROM {{ ref('atm_geographic_area') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'ECAT_COUNTRY'
        AND geographic_area_tp_code = 'COUNTRY'
)

SELECT
    CAST(related_party.sp_code AS string)                         AS practitioner_code,
    CAST(related_party.sp_related_party_code AS string)           AS related_party_code,
    CAST(related_party.related_individual_full_nm AS string)      AS related_individual_full_nm,
    CAST(related_party.rltnp_tp_code AS string)                   AS rltnp_tp_code,
    CAST(relationship_type_lookup.cl_nm AS string)                                 AS rltnp_tp_nm,
    CAST(related_party.related_individual_occupation AS string)   AS related_individual_occupation,
    CAST(related_party.related_individual_workplace AS string)    AS related_individual_workplace,
    CAST(related_party.related_individual_identity_nbr AS string) AS related_individual_identity_nbr,
    CAST(geographic_area.geographic_area_code AS string)               AS country_code,
    CAST(geographic_area.geographic_area_nm AS string)                 AS country_nm,
    CAST(related_party.related_individual_adr AS string)          AS related_individual_adr,
    CAST(related_party.src_stm_code AS string)                    AS src_stm_code
FROM related_party
LEFT JOIN relationship_type_lookup
    ON relationship_type_lookup.cl_code = related_party.rltnp_tp_code
LEFT JOIN geographic_area
    ON geographic_area.geographic_area_id = related_party.country_id
