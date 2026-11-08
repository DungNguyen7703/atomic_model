/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_exam_details
* Program name: Staging NHNCK.EXAM_DETAILS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (13 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                      AS id
    , CAST(professional_id AS bigint)       AS professional_id
    , CAST(certificate_id AS bigint)        AS certificate_id
    , CAST(exam_session_id AS bigint)       AS exam_session_id
    , CAST(sequence_number AS bigint)       AS sequence_number
    , CAST(exam_number AS string)           AS exam_number
    , CAST(law_score AS bigint)             AS law_score
    , CAST(law_result AS bigint)            AS law_result
    , CAST(specialization_score AS bigint)  AS specialization_score
    , CAST(specialization_result AS bigint) AS specialization_result
    , CAST(result AS bigint)                AS result
    , CAST(note AS string)                  AS note
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(updated_at AS timestamp)         AS updated_at
    , CAST(created_by AS bigint)            AS created_by
    , CAST(updated_by AS bigint)            AS updated_by
    , CAST(application_id AS bigint)        AS application_id
FROM {{ source('source_nhnck', 'raw_exam_details') }}