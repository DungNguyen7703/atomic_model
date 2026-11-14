/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_citizen_reception
* Program name: Staging THANHTRA.CITIZEN_RECEPTION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot); them cot petition_attached; doi thu tu cot.
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
    , CAST(petition_attached AS int)    AS petition_attached
    , CAST(petition_category AS string) AS petition_category
    , CAST(processing_status AS string) AS processing_status
    , CAST(petition_id AS string)       AS petition_id
    , CAST(note AS string)              AS note
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)        AS created_by
    , CAST(last_modified_by AS string)  AS last_modified_by
    , CAST(version AS bigint)           AS version
    , CAST(deleted AS int)              AS deleted
    , CAST(has_petition AS int)         AS has_petition
FROM {{ source('source_thanhtra', 'raw_citizen_reception') }}