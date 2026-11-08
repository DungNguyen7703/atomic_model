/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_documents
* Program name: Staging NHNCK.APPLICATION_DOCUMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (7 cot); kieu date sang timestamp (3 cot); them cot mcdt_ma_thanh_phan_hoso, submit_later.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                        AS id
    , CAST(application_id AS bigint)          AS application_id
    , CAST(document_id AS bigint)             AS document_id
    , CAST(description AS string)             AS description
    , CAST(status AS bigint)                  AS status
    , CAST(assignee_id AS bigint)             AS assignee_id
    , CAST(files AS string)                   AS files
    , CAST(document_name AS string)           AS document_name
    , CAST(note AS string)                    AS note
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(appraisaled_at AS timestamp)       AS appraisaled_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by AS bigint)              AS created_by
    , CAST(updated_by AS bigint)              AS updated_by
    , CAST(mcdt_ma_thanh_phan_hoso AS string) AS mcdt_ma_thanh_phan_hoso
    , CAST(submit_later AS int)               AS submit_later
FROM {{ source('source_nhnck', 'raw_application_documents') }}