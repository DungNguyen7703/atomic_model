/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_organization_report_yearlys
* Program name: Staging NHNCK.ORGANIZATION_REPORT_YEARLYS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (5 cot); kieu date sang timestamp (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                   AS id
    , CAST(organization_id AS bigint)    AS organization_id
    , CAST(name AS string)               AS name
    , CAST(submission_date AS timestamp) AS submission_date
    , CAST(year AS string)               AS year
    , CAST(type AS string)               AS type
    , CAST(file_path AS string)          AS file_path
    , CAST(status AS bigint)             AS status
    , CAST(created_at AS timestamp)      AS created_at
    , CAST(updated_at AS timestamp)      AS updated_at
    , CAST(created_by AS bigint)         AS created_by
    , CAST(updated_by AS bigint)         AS updated_by
FROM {{ source('source_nhnck', 'raw_organization_report_yearlys') }}