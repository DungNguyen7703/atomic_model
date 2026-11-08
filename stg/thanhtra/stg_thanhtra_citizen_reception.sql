/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_citizen_reception
* Program name: Staging THANHTRA.CITIZEN_RECEPTION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                  AS id
    , CAST(reception_date AS date)      AS reception_date
    , CAST(receiver_id AS string)       AS receiver_id
    , CAST(receiver_name AS string)     AS receiver_name
    , CAST(subject_type AS string)      AS subject_type
    , CAST(subject_name AS string)      AS subject_name
    , CAST(number_of_people AS int)     AS number_of_people
    , CAST(summary AS string)           AS summary
    , CAST(has_petition AS int)         AS has_petition
    , CAST(petition_category AS string) AS petition_category
    , CAST(processing_status AS string) AS processing_status
    , CAST(petition_id AS string)       AS petition_id
    , CAST(note AS string)              AS note
    , CAST(created_at AS date)          AS created_at
    , CAST(last_modified_at AS date)    AS last_modified_at
    , CAST(created_by AS string)        AS created_by
    , CAST(last_modified_by AS string)  AS last_modified_by
    , CAST(version AS bigint)           AS version
    , CAST(deleted AS int)              AS deleted
FROM {{ source('source_thanhtra', 'raw_citizen_reception') }}