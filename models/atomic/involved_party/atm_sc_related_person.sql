/*
*--------------------------------------------------------------------*
* Program code: atm_sc_related_person
* Program name: Atomic Securities Company Related Person
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_re_pe AS (
    SELECT
        id
        , sc_firm_info_id
        , entity_type
        , gender
        , position_id
        , country_id
        , full_name
        , org_name_en
        , org_short_name
        , date_of_birth
        , representative_title
        , legal_representative
        , appointment_date
        , workplace
        , relationship
        , ownership_ratio
        , ownership_ratio_date
        , shares_count
        , founding_shareholder
        , note
    FROM {{ ref('ods_scms_sc_firm_related_person') }}
),

sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
),

ca_po AS (
    SELECT
        id
        , position_code
    FROM {{ ref('ods_scms_cat_position') }}
),

ca_na AS (
    SELECT
        id
        , nationality_code
    FROM {{ ref('ods_scms_cat_nationality') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_RELATED_PERSON', "sc_fi_re_pe.id") }} AS sc_related_person_id
    , CAST(sc_fi_re_pe.id AS string)                                                     AS sc_related_person_code
    , CAST('SCMS_SC_FIRM_RELATED_PERSON' AS string)                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}          AS sc_id
    , CAST(sc_fi_in.code AS string)                                                      AS sc_code
    , CAST(sc_fi_re_pe.entity_type AS string)                                            AS entity_tp_code
    , CAST(sc_fi_re_pe.gender AS string)                                                 AS gender_code
    , {{ generate_surrogate_key_bigint('SCMS_CAT_POSITION', "ca_po.position_code") }}    AS cl_sc_position_id
    , CAST(ca_po.position_code AS string)                                                AS cl_sc_position_code
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "ca_na.nationality_code") }}      AS country_id
    , CAST(ca_na.nationality_code AS string)                                             AS country_code
    , CAST(sc_fi_re_pe.full_name AS string)                                              AS full_nm
    , CAST(sc_fi_re_pe.org_name_en AS string)                                            AS english_nm
    , CAST(sc_fi_re_pe.org_short_name AS string)                                         AS short_nm
    , CAST(sc_fi_re_pe.date_of_birth AS date)                                            AS dt_of_birth
    , CAST(sc_fi_re_pe.representative_title AS string)                                   AS representative_title
    , CAST(sc_fi_re_pe.legal_representative AS string)                                   AS legal_representative
    , CAST(sc_fi_re_pe.appointment_date AS date)                                         AS appointment_dt
    , CAST(sc_fi_re_pe.workplace AS string)                                              AS workplace
    , CAST(sc_fi_re_pe.relationship AS string)                                           AS rltnp
    , CAST(sc_fi_re_pe.ownership_ratio AS decimal(5,2))                                  AS ownership_ratio
    , CAST(sc_fi_re_pe.ownership_ratio_date AS date)                                     AS ownership_ratio_dt
    , CAST(sc_fi_re_pe.shares_count AS int)                                              AS shares_count
    , CAST(sc_fi_re_pe.founding_shareholder AS int)                                      AS founding_shareholder_ind
    , CAST(sc_fi_re_pe.note AS string)                                                   AS note
FROM sc_fi_re_pe
    LEFT JOIN sc_fi_in ON sc_fi_re_pe.SC_FIRM_INFO_ID = sc_fi_in.ID
    LEFT JOIN ca_po ON sc_fi_re_pe.POSITION_ID = ca_po.ID
    LEFT JOIN ca_na ON sc_fi_re_pe.COUNTRY_ID = ca_na.ID