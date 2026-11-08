/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_signing_note
* Program name: Staging NHNCK.SIGNING_NOTE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu float sang double (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                AS id
    , CAST(document_path AS string)   AS document_path
    , CAST(page_number AS int)        AS page_number
    , CAST(x_ratio AS double)         AS x_ratio
    , CAST(y_ratio AS double)         AS y_ratio
    , CAST(content AS string)         AS content
    , CAST(author_user_ref AS string) AS author_user_ref
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
FROM {{ source('source_nhnck', 'raw_signing_note') }}
