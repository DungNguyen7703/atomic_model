/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_document_histories
* Program name: Staging NHNCK.APPLICATION_DOCUMENT_HISTORIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (6 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)               AS id
    , CAST(application_id AS bigint) AS application_id
    , CAST(document_id AS bigint)    AS document_id
    , CAST(is_invalid AS int)        AS is_invalid
    , CAST(is_incomplete AS int)     AS is_incomplete
    , CAST(description AS string)    AS description
    , CAST(status AS bigint)         AS status
    , CAST(created_at AS timestamp)  AS created_at
    , CAST(updated_by AS bigint)     AS updated_by
    , CAST(updated_at AS timestamp)  AS updated_at
    , CAST(created_by AS bigint)     AS created_by
FROM {{ source('source_nhnck', 'raw_application_document_histories') }}