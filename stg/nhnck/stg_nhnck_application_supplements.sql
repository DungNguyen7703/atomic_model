/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_supplements
* Program name: Staging NHNCK.APPLICATION_SUPPLEMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (5 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(application_id AS bigint)  AS application_id
    , CAST(supplement_date AS date)   AS supplement_date
    , CAST(content AS string)         AS content
    , CAST(supplemented_by AS bigint) AS supplemented_by
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by AS bigint)      AS created_by
    , CAST(updated_by AS bigint)      AS updated_by
FROM {{ source('source_nhnck', 'raw_application_supplements') }}