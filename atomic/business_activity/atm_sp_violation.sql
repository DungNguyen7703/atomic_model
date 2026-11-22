/*
*--------------------------------------------------------------------*
* Program code: atm_sp_violation
* Program name: Atomic SP Violation
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH vi AS (
    SELECT
        id
        , professional_id
        , decision_id
        , full_name
        , birth_date
        , identity_number
        , note
        , status
        , type
    FROM {{ ref('ods_nhnck_violations') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_VIOLATIONS', "id") }}                   AS sp_violation_id
    , CAST(id AS string)                                                            AS sp_violation_code
    , CAST('NHNCK_VIOLATIONS' AS string)                                            AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "professional_id") }} AS sp_id
    , CAST(professional_id AS string)                                               AS sp_code
    , {{ generate_surrogate_key_bigint('NHNCK_DECISIONS', "decision_id") }}         AS sp_license_decision_document_id
    , CAST(decision_id AS string)                                                   AS sp_license_decision_document_code
    , CAST(full_name AS string)                                                     AS full_nm
    , CAST(birth_date AS date)                                                      AS dt_of_birth
    , CAST(identity_number AS string)                                               AS identification_nbr
    , CAST(note AS string)                                                          AS note
    , CAST(status AS string)                                                        AS violation_status_code
    , CAST(type AS string)                                                          AS violation_tp_code
FROM vi
