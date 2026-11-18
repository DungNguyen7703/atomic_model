/*
*--------------------------------------------------------------------*
* Program code: atm_sc_insider_related_person
* Program name: Atomic Securities Company Insider Related Person
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_in_re AS (
    SELECT
        id
        , sc_firm_info_id
        , senior_personnel_id
        , entity_type
        , gender
        , full_name
        , name_en
        , short_name
        , date_of_birth
        , issue_date
        , issue_place
        , nationality_id
        , relationship
        , relation_start_date
        , ownership_ratio
        , ownership_ratio_date
        , shares_count
        , founding_shareholder
        , legal_representative_name
        , representative_position
        , note
        , created_at
    FROM {{ ref('ods_scms_sc_firm_insider_relation') }}
),

sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
),

ca_na AS (
    SELECT
        id
        , nationality_code
    FROM {{ ref('ods_scms_cat_nationality') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INSIDER_RELATION', "sc_fi_in_re.id") }}                    AS sc_insider_related_person_id
    , CAST(sc_fi_in_re.id AS string)                                                                          AS sc_insider_related_person_code
    , CAST('SCMS_SC_FIRM_INSIDER_RELATION' AS string)                                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                               AS sc_id
    , CAST(sc_fi_in.code AS string)                                                                           AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SENIOR_PERSONNEL', "sc_fi_in_re.senior_personnel_id") }} AS sc_senior_personnel_id
    , CAST(sc_fi_in_re.senior_personnel_id AS string)                                                         AS sc_senior_personnel_code
    , CAST(sc_fi_in_re.entity_type AS string)                                                                 AS entity_tp_code
    , CAST(sc_fi_in_re.gender AS string)                                                                      AS gender_code
    , CAST(sc_fi_in_re.full_name AS string)                                                                   AS full_nm
    , CAST(sc_fi_in_re.name_en AS string)                                                                     AS english_nm
    , CAST(sc_fi_in_re.short_name AS string)                                                                  AS short_nm
    , CAST(sc_fi_in_re.date_of_birth AS date)                                                                 AS dt_of_birth
    , CAST(sc_fi_in_re.issue_date AS date)                                                                    AS issue_dt
    , CAST(sc_fi_in_re.issue_place AS string)                                                                 AS issue_place
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "ca_na.nationality_code") }}                           AS nationality_id
    , CAST(ca_na.nationality_code AS string)                                                                  AS nationality_code
    , CAST(sc_fi_in_re.relationship AS string)                                                                AS rltnp
    , CAST(sc_fi_in_re.relation_start_date AS date)                                                           AS relation_start_dt
    , CAST(sc_fi_in_re.ownership_ratio AS decimal(5,2))                                                       AS ownership_ratio
    , CAST(sc_fi_in_re.ownership_ratio_date AS date)                                                          AS ownership_ratio_dt
    , CAST(sc_fi_in_re.shares_count AS int)                                                                   AS shares_count
    , CAST(sc_fi_in_re.founding_shareholder AS int)                                                           AS founding_shareholder_ind
    , CAST(sc_fi_in_re.legal_representative_name AS string)                                                   AS legal_representative_nm
    , CAST(sc_fi_in_re.representative_position AS string)                                                     AS representative_position
    , CAST(sc_fi_in_re.note AS string)                                                                        AS note
    , CAST(sc_fi_in_re.created_at AS timestamp)                                                               AS src_rcrd_isrt_tms
FROM sc_fi_in_re
    LEFT JOIN sc_fi_in ON sc_fi_in_re.SC_FIRM_INFO_ID = sc_fi_in.ID
    LEFT JOIN ca_na ON sc_fi_in_re.NATIONALITY_ID = ca_na.ID