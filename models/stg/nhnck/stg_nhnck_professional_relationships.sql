/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_professional_relationships
* Program name: Staging NHNCK.PROFESSIONAL_RELATIONSHIPS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (7 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(professional_id AS bigint)   AS professional_id
    , CAST(relationship_type AS bigint) AS relationship_type
    , CAST(full_name AS string)         AS full_name
    , CAST(birth_year AS bigint)        AS birth_year
    , CAST(address AS string)           AS address
    , CAST(occupation AS string)        AS occupation
    , CAST(workplace AS string)         AS workplace
    , CAST(note AS string)              AS note
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(country_id AS bigint)        AS country_id
    , CAST(identity_id AS string)       AS identity_id
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(created_by AS bigint)        AS created_by
    , CAST(updated_by AS bigint)        AS updated_by
FROM {{ source('source_nhnck', 'raw_professional_relationships') }}