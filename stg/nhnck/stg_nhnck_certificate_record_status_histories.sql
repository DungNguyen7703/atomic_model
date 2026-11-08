/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_record_status_histories
* Program name: Staging NHNCK.CERTIFICATE_RECORD_STATUS_HISTORIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (7 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                      AS id
    , CAST(certificate_record_id AS bigint) AS certificate_record_id
    , CAST(update_type AS string)           AS update_type
    , CAST(old_status AS bigint)            AS old_status
    , CAST(new_status AS bigint)            AS new_status
    , CAST(decision_id AS bigint)           AS decision_id
    , CAST(reason AS string)                AS reason
    , CAST(created_by AS bigint)            AS created_by
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(updated_at AS timestamp)         AS updated_at
    , CAST(updated_by AS bigint)            AS updated_by
FROM {{ source('source_nhnck', 'raw_certificate_record_status_histories') }}