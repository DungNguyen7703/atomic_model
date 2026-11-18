/*
*--------------------------------------------------------------------*
* Program code: stg_fms_tl_pro_cert
* Program name: Staging FMS.TL_PRO_CERT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo FMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                          AS id
    , HEX(tlpro_id)                    AS tlpro_id
    , CAST(cert_no AS string)          AS cert_no
    , CAST(cert_date AS date)          AS cert_date
    , HEX(busi_id)                     AS busi_id
    , CAST(is_used AS int)             AS is_used
    , CAST(description AS string)      AS description
    , CAST(deleted AS int)             AS deleted
    , CAST(date_created AS timestamp)  AS date_created
    , CAST(created_by AS string)       AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)        AS modify_by
    , CAST(confirm_status AS int)      AS confirm_status
    , CAST(cert_source AS string)      AS cert_source
    , CAST(nhn_status AS int)          AS nhn_status
FROM {{ source('source_fms', 'raw_tl_pro_cert') }}