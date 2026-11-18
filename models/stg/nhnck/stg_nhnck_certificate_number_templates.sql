/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_number_templates
* Program name: Staging NHNCK.CERTIFICATE_NUMBER_TEMPLATES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (5 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)               AS id
    , CAST(code AS string)           AS code
    , CAST(certificate_id AS bigint) AS certificate_id
    , CAST(type AS bigint)           AS type
    , CAST(is_default AS int)        AS is_default
    , CAST(name AS string)           AS name
    , CAST(created_at AS timestamp)  AS created_at
    , CAST(updated_at AS timestamp)  AS updated_at
    , CAST(created_by AS bigint)     AS created_by
    , CAST(updated_by AS bigint)     AS updated_by
FROM {{ source('source_nhnck', 'raw_certificate_number_templates') }}