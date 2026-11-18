/*
*--------------------------------------------------------------------*
* Program code: stg_fms_tl_pro_cert_reconcile_log
* Program name: Staging FMS.TL_PRO_CERT_RECONCILE_LOG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo FMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                         AS id
    , HEX(tlpro_id)                   AS tlpro_id
    , CAST(id_no AS string)           AS id_no
    , CAST(started_at AS timestamp)   AS started_at
    , CAST(finished_at AS timestamp)  AS finished_at
    , CAST(status AS string)          AS status
    , CAST(attempt_no AS int)         AS attempt_no
    , CAST(request_summary AS string) AS request_summary
    , CAST(response_json AS string)   AS response_json
    , CAST(result_summary AS string)  AS result_summary
    , CAST(certs_added AS bigint)     AS certs_added
    , CAST(certs_updated AS bigint)   AS certs_updated
    , CAST(error_message AS string)   AS error_message
    , CAST(trigger_source AS string)  AS trigger_source
FROM {{ source('source_fms', 'raw_tl_pro_cert_reconcile_log') }}