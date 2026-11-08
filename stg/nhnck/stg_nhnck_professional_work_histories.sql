/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_professional_work_histories
* Program name: Staging NHNCK.PROFESSIONAL_WORK_HISTORIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (6 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(organization_id AS bigint) AS organization_id
    , CAST(professional_id AS bigint) AS professional_id
    , CAST(unit_name AS string)       AS unit_name
    , CAST(start_date AS date)        AS start_date
    , CAST(end_date AS date)          AS end_date
    , CAST(workplace AS string)       AS workplace
    , CAST(position_id AS bigint)     AS position_id
    , CAST(position_name AS string)   AS position_name
    , CAST(awards AS string)          AS awards
    , CAST(disciplines AS string)     AS disciplines
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(created_by AS bigint)      AS created_by
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(updated_by AS bigint)      AS updated_by
FROM {{ source('source_nhnck', 'raw_professional_work_histories') }}