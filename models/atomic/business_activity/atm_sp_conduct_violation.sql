/*
*--------------------------------------------------------------------*
* Program code: atm_sp_conduct_violation
* Program name: Atomic Securities Practitioner Conduct Violation
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH viol AS (
    SELECT
        id
        , professional_id
        , decision_id
        , full_name
        , birth_date
        , identity_number
        , created_at
        , note
        , status
        , type
    FROM {{ ref('ods_nhnck_violations') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_VIOLATIONS', "viol.id") }}                   AS sp_conduct_violation_id
    , CAST(viol.id AS string)                                                            AS sp_conduct_violation_code
    , CAST('NHNCK_VIOLATIONS' AS string)                                                 AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "viol.professional_id") }} AS sp_id
    , CAST(viol.professional_id AS string)                                               AS sp_code
    , {{ generate_surrogate_key_bigint('NHNCK_DECISIONS', "viol.decision_id") }}         AS sp_license_decision_document_id
    , CAST(viol.decision_id AS string)                                                   AS sp_license_decision_document_code
    , CAST(viol.full_name AS string)                                                     AS practitioner_nm_at_violation
    , CAST(viol.birth_date AS date)                                                      AS practitioner_birth_dt_at_violation
    , CAST(viol.identity_number AS string)                                               AS practitioner_identity_nbr_at_violation
    , CAST(viol.created_at AS timestamp)                                                 AS violation_record_dt
    , CAST(viol.note AS string)                                                          AS note
    , CAST(viol.status AS string)                                                        AS violation_status_code
    , CAST(viol.type AS string)                                                          AS violation_tp_code
FROM viol