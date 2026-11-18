/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_violations
* Program name: Staging NHNCK.VIOLATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (7 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(professional_id AS bigint) AS professional_id
    , CAST(full_name AS string)       AS full_name
    , CAST(birth_date AS date)        AS birth_date
    , CAST(identity_number AS string) AS identity_number
    , CAST(note AS string)            AS note
    , CAST(created_by AS bigint)      AS created_by
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(decision_id AS bigint)     AS decision_id
    , CAST(type AS bigint)            AS type
    , CAST(status AS bigint)          AS status
    , CAST(updated_by AS bigint)      AS updated_by
    , CAST(updated_at AS timestamp)   AS updated_at
FROM {{ source('source_nhnck', 'raw_violations') }}