/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_post_inspection_processing
* Program name: Staging THANHTRA.POST_INSPECTION_PROCESSING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(inspection_conclusion_id AS string) AS inspection_conclusion_id
    , CAST(requirement_type AS string)         AS requirement_type
    , CAST(responsible_party AS string)        AS responsible_party
    , CAST(due_date AS date)                   AS due_date
    , CAST(status AS string)                   AS status
    , CAST(implementation_notes AS string)     AS implementation_notes
    , CAST(last_updated_date AS date)          AS last_updated_date
    , CAST(monitoring_officer_id AS string)    AS monitoring_officer_id
    , CAST(monitoring_officer_name AS string)  AS monitoring_officer_name
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(created_by AS string)               AS created_by
    , CAST(last_modified_at AS timestamp)      AS last_modified_at
    , CAST(last_modified_by AS string)         AS last_modified_by
    , CAST(version AS bigint)                  AS version
    , CAST(deleted AS int)                     AS deleted
    , CAST(requirement_summary AS string)      AS requirement_summary
    , CAST(result_summary AS string)           AS result_summary
FROM {{ source('source_thanhtra', 'raw_post_inspection_processing') }}