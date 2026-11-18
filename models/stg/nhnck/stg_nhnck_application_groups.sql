/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_groups
* Program name: Staging NHNCK.APPLICATION_GROUPS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (8 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                   AS id
    , CAST(group_name AS string)         AS group_name
    , CAST(description AS string)        AS description
    , CAST(status AS bigint)             AS status
    , CAST(decision_id AS bigint)        AS decision_id
    , CAST(group_created_date AS date)   AS group_created_date
    , CAST(group_completed_date AS date) AS group_completed_date
    , CAST(notes AS string)              AS notes
    , CAST(application_count AS bigint)  AS application_count
    , CAST(created_at AS timestamp)      AS created_at
    , CAST(updated_at AS timestamp)      AS updated_at
    , CAST(created_by AS bigint)         AS created_by
    , CAST(updated_by AS bigint)         AS updated_by
    , CAST(application_type AS bigint)   AS application_type
    , CAST(submited_date AS date)        AS submited_date
    , CAST(submited_by AS bigint)        AS submited_by
FROM {{ source('source_nhnck', 'raw_application_groups') }}