/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_re_exams
* Program name: Staging NHNCK.APPLICATION_RE_EXAMS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (7 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(application_id AS bigint)    AS application_id
    , CAST(exam_detail_id AS bigint)    AS exam_detail_id
    , CAST(re_application_id AS bigint) AS re_application_id
    , CAST(status AS bigint)            AS status
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(created_by AS bigint)        AS created_by
    , CAST(updated_by AS bigint)        AS updated_by
FROM {{ source('source_nhnck', 'raw_application_re_exams') }}