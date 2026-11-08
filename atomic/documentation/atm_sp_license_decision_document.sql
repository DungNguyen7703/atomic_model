/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_decision_document
* Program name: Atomic Securities Practitioner License Decision Document
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH deci AS (
    SELECT
        id
        , decision_number
        , title
        , reference
        , decision_content
        , signed_date
        , signatory
        , position
        , decision_unit
        , file_name
        , file_path
        , decision_type_id
        , content
        , is_active
    FROM {{ ref('ods_nhnck_decisions') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_DECISIONS', "deci.id") }} AS sp_license_decision_document_id
    , CAST(deci.id AS string)                                         AS sp_license_decision_document_code
    , CAST('NHNCK_DECISIONS' AS string)                               AS src_stm_code
    , CAST(deci.decision_number AS string)                            AS decision_nbr
    , CAST(deci.title AS string)                                      AS decision_title
    , CAST(deci.reference AS string)                                  AS legal_reference
    , CAST(deci.decision_content AS string)                           AS decision_content
    , CAST(deci.signed_date AS date)                                  AS decision_signed_dt
    , CAST(deci.signatory AS string)                                  AS signatory_nm
    , CAST(deci.position AS string)                                   AS signatory_position
    , CAST(deci.decision_unit AS string)                              AS issuing_organization_nm
    , CAST(deci.file_name AS string)                                  AS attachment_file_nm
    , CAST(deci.file_path AS string)                                  AS attachment_file_path
    , CAST(deci.decision_type_id AS string)                           AS decision_tp_code
    , CAST(deci.content AS string)                                    AS notification_content
    , CAST(deci.is_active AS int)                                     AS active_flag
FROM deci