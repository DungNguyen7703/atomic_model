/*
*--------------------------------------------------------------------*
* Program code: stg_ids_identity
* Program name: Staging IDS.IDENTITY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                         AS id
    , CAST(legal_entity_id AS int)          AS legal_entity_id
    , CAST(identity_type_cd AS string)      AS identity_type_cd
    , CAST(identity_no AS string)           AS identity_no
    , CAST(identity_issued_date AS date)    AS identity_issued_date
    , CAST(identity_issued_place AS string) AS identity_issued_place
    , CAST(created_by AS string)            AS created_by
    , CAST(created_date AS date)            AS created_date
    , CAST(updated_by AS string)            AS updated_by
    , CAST(updated_date AS date)            AS updated_date
    , CAST(delete_flg AS int)               AS delete_flg
FROM {{ source('source_ids', 'raw_identity') }}