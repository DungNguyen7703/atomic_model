/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_specializations
* Program name: Staging NHNCK.SPECIALIZATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (4 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                    AS id
    , CAST(specialization_code AS string) AS specialization_code
    , CAST(specialization_name AS string) AS specialization_name
    , CAST(reference AS string)           AS reference
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(created_by AS bigint)          AS created_by
    , CAST(updated_at AS timestamp)       AS updated_at
    , CAST(is_active AS int)              AS is_active
    , CAST(is_original_data AS int)       AS is_original_data
    , CAST(status AS bigint)              AS status
    , CAST(mcdt_code AS string)           AS mcdt_code
    , CAST(updated_by AS bigint)          AS updated_by
FROM {{ source('source_nhnck', 'raw_specializations') }}