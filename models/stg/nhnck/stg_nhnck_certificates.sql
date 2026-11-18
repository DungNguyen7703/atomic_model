/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificates
* Program name: Staging NHNCK.CERTIFICATES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (6 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                 AS id
    , CAST(certificate_code AS string) AS certificate_code
    , CAST(certificate_name AS string) AS certificate_name
    , CAST(description AS string)      AS description
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(is_displayed AS int)        AS is_displayed
    , CAST(sort_order AS bigint)       AS sort_order
    , CAST(is_original_data AS int)    AS is_original_data
    , CAST(processing_days AS bigint)  AS processing_days
    , CAST(status AS bigint)           AS status
    , CAST(created_by AS bigint)       AS created_by
    , CAST(updated_by AS bigint)       AS updated_by
FROM {{ source('source_nhnck', 'raw_certificates') }}