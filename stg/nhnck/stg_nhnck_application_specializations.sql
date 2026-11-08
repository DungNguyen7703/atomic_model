/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_specializations
* Program name: Staging NHNCK.APPLICATION_SPECIALIZATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (7 cot); kieu date sang timestamp (3 cot); them cot mcdt_ma_thanh_phan_hoso.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                        AS id
    , CAST(application_id AS bigint)          AS application_id
    , CAST(specialization_id AS bigint)       AS specialization_id
    , CAST(issue_date AS date)                AS issue_date
    , CAST(issue_place AS string)             AS issue_place
    , CAST(status AS bigint)                  AS status
    , CAST(note AS string)                    AS note
    , CAST(assignee_id AS bigint)             AS assignee_id
    , CAST(appraisaled_at AS timestamp)       AS appraisaled_at
    , CAST(created_by AS bigint)              AS created_by
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(files AS string)                   AS files
    , CAST(updated_by AS bigint)              AS updated_by
    , CAST(mcdt_ma_thanh_phan_hoso AS string) AS mcdt_ma_thanh_phan_hoso
FROM {{ source('source_nhnck', 'raw_application_specializations') }}