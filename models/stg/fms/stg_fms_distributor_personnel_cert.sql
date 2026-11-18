/*
*--------------------------------------------------------------------*
* Program code: stg_fms_distributor_personnel_cert
* Program name: Staging FMS.DISTRIBUTOR_PERSONNEL_CERT
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
    , HEX(distributor_personnel_id)    AS distributor_personnel_id
    , CAST(has_cert AS int)            AS has_cert
    , CAST(cert_no AS string)          AS cert_no
    , CAST(cert_date AS date)          AS cert_date
    , CAST(note AS string)             AS note
    , CAST(cert_basic AS int)          AS cert_basic
    , CAST(cert_law AS int)            AS cert_law
    , CAST(cert_analysis AS int)       AS cert_analysis
    , CAST(cert_brokerage AS int)      AS cert_brokerage
    , CAST(deleted AS int)             AS deleted
    , CAST(date_created AS timestamp)  AS date_created
    , CAST(created_by AS string)       AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)        AS modify_by
    , CAST(cert_type AS int)           AS cert_type
FROM {{ source('source_fms', 'raw_distributor_personnel_cert') }}