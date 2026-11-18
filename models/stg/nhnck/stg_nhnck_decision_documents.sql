/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_decision_documents
* Program name: Staging NHNCK.DECISION_DOCUMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (6 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(decision_id AS bigint)     AS decision_id
    , CAST(type AS bigint)            AS type
    , CAST(decision_number AS string) AS decision_number
    , CAST(position AS string)        AS position
    , CAST(file_path AS string)       AS file_path
    , CAST(signed_by AS string)       AS signed_by
    , CAST(signed_date AS date)       AS signed_date
    , CAST(status AS bigint)          AS status
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by AS bigint)      AS created_by
    , CAST(updated_by AS bigint)      AS updated_by
FROM {{ source('source_nhnck', 'raw_decision_documents') }}