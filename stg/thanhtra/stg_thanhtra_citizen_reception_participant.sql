/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_citizen_reception_participant
* Program name: Staging THANHTRA.CITIZEN_RECEPTION_PARTICIPANT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-08
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-08		tuan.nguyenvanb		[MOI] Bo sung STG theo THANHTRA_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                   AS id
    , CAST(citizen_reception_id AS string) AS citizen_reception_id
    , CAST(participant_type AS string)     AS participant_type
    , CAST(user_id AS string)              AS user_id
    , CAST(user_full_name AS string)       AS user_full_name
    , CAST(user_account AS string)         AS user_account
    , CAST(department_id AS string)        AS department_id
    , CAST(department_name AS string)      AS department_name
    , CAST(sort_order AS int)              AS sort_order
    , CAST(created_at AS date)             AS created_at
    , CAST(last_modified_at AS date)       AS last_modified_at
    , CAST(created_by AS string)           AS created_by
    , CAST(last_modified_by AS string)     AS last_modified_by
    , CAST(version AS bigint)              AS version
    , CAST(deleted AS int)                 AS deleted
FROM {{ source('source_thanhtra', 'raw_citizen_reception_participant') }}