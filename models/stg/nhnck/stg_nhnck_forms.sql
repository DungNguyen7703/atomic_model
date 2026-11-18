/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_forms
* Program name: Staging NHNCK.FORMS
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
    , CAST(certificate_id AS bigint) AS certificate_id
    , CAST(form_name AS string)      AS form_name
    , CAST(reference AS string)      AS reference
    , CAST(description AS string)    AS description
    , CAST(file_name AS string)      AS file_name
    , CAST(file_path AS string)      AS file_path
    , CAST(created_at AS timestamp)  AS created_at
    , CAST(created_by AS bigint)     AS created_by
    , CAST(updated_at AS timestamp)  AS updated_at
    , CAST(status AS bigint)         AS status
    , CAST(sort_order AS bigint)     AS sort_order
    , CAST(is_featured AS int)       AS is_featured
    , CAST(updated_by AS bigint)     AS updated_by
FROM {{ source('source_nhnck', 'raw_forms') }}