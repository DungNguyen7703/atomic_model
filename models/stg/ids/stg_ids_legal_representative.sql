/*
*--------------------------------------------------------------------*
* Program code: stg_ids_legal_representative
* Program name: Staging IDS.LEGAL_REPRESENTATIVE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                    AS id
    , CAST(company_profile_id AS int)  AS company_profile_id
    , CAST(name AS string)             AS name
    , CAST(position_cd AS string)      AS position_cd
    , CAST(appointment_date AS date)   AS appointment_date
    , CAST(phone_no AS string)         AS phone_no
    , CAST(email AS string)            AS email
    , CAST(identity_no AS string)      AS identity_no
    , CAST(issue_date AS date)         AS issue_date
    , CAST(issue_place AS string)      AS issue_place
    , CAST(representative_role AS int) AS representative_role
    , CAST(created_by AS string)       AS created_by
    , CAST(created_date AS date)       AS created_date
    , CAST(updated_by AS string)       AS updated_by
    , CAST(updated_date AS date)       AS updated_date
    , CAST(delete_flg AS int)          AS delete_flg
FROM {{ source('source_ids', 'raw_legal_representative') }}