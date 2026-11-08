/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_specializations
* Program name: Staging NHNCK.CERTIFICATE_SPECIALIZATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (5 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(certificate_id AS bigint)    AS certificate_id
    , CAST(specialization_id AS bigint) AS specialization_id
    , CAST(sort_order AS bigint)        AS sort_order
    , CAST(document_type AS bigint)     AS document_type
    , CAST(is_required AS int)          AS is_required
FROM {{ source('source_nhnck', 'raw_certificate_specializations') }}