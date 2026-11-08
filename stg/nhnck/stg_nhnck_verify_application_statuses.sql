/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_verify_application_statuses
* Program name: Staging NHNCK.VERIFY_APPLICATION_STATUSES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (8 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                   AS id
    , CAST(application_id AS bigint)     AS application_id
    , CAST(status_id AS bigint)          AS status_id
    , CAST(prev_status_id AS bigint)     AS prev_status_id
    , CAST(status AS bigint)             AS status
    , CAST(reason AS string)             AS reason
    , CAST(spec_reason AS string)        AS spec_reason
    , CAST(org_reason AS string)         AS org_reason
    , CAST(overview_reason AS string)    AS overview_reason
    , CAST(overview_file_path AS string) AS overview_file_path
    , CAST(verified_by AS bigint)        AS verified_by
    , CAST(created_by AS bigint)         AS created_by
    , CAST(created_at AS timestamp)      AS created_at
    , CAST(updated_by AS bigint)         AS updated_by
    , CAST(updated_at AS timestamp)      AS updated_at
FROM {{ source('source_nhnck', 'raw_verify_application_statuses') }}