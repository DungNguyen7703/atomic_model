/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_exam_session_fees
* Program name: Staging NHNCK.EXAM_SESSION_FEES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (6 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(exam_session_id AS bigint)   AS exam_session_id
    , CAST(certificate_id AS bigint)    AS certificate_id
    , CAST(fee_exam AS decimal(18,2))   AS fee_exam
    , CAST(fee_appeal AS decimal(18,2)) AS fee_appeal
    , CAST(status AS bigint)            AS status
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(created_by AS bigint)        AS created_by
    , CAST(updated_by AS bigint)        AS updated_by
FROM {{ source('source_nhnck', 'raw_exam_session_fees') }}