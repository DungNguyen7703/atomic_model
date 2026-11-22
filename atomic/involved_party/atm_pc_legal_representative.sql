/*
*--------------------------------------------------------------------*
* Program code: atm_pc_legal_representative
* Program name: Atomic Pc Legal Representative
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , company_profile_id
        , name
        , position_cd
        , appointment_date
        , identity_no
        , issue_date
        , issue_place
        , representative_role
    FROM {{ ref('ods_ids_legal_representative') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_LEGAL_REPRESENTATIVE', "id") }}               AS pc_legal_representative_id
    , CAST(id AS string)                                                                AS pc_legal_representative_code
    , CAST('IDS_LEGAL_REPRESENTATIVE' AS string)                                        AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , CAST(name AS string)                                                              AS pc_legal_representative_nm
    , CAST(position_cd AS string)                                                       AS position_code
    , CAST(appointment_date AS date)                                                    AS appointment_dt
    , CAST(representative_role AS int)                                                  AS representative_role_ind
    , CAST(identity_no AS string)                                                       AS identification_nbr
    , CAST(issue_date AS date)                                                          AS identification_issue_dt
    , CAST(issue_place AS string)                                                       AS identification_issue_place
FROM src
