/*
*--------------------------------------------------------------------*
* Program code: stg_knt_report_comparison_header
* Program name: Staging KNT.REPORT_COMPARISON_HEADER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                     AS id
    , CAST(tax_code AS string)            AS tax_code
    , CAST(declaration_period AS string)  AS declaration_period
    , CAST(declaration_code AS string)    AS declaration_code
    , CAST(tax_report_id AS int)          AS tax_report_id
    , CAST(ssc_report_id AS int)          AS ssc_report_id
    , CAST(tax_msg_packet_id AS int)      AS tax_msg_packet_id
    , CAST(ssc_msg_packet_id AS int)      AS ssc_msg_packet_id
    , CAST(tax_packet_code AS string)     AS tax_packet_code
    , CAST(ssc_packet_code AS string)     AS ssc_packet_code
    , CAST(representative_name AS string) AS representative_name
    , CAST(report_name AS string)         AS report_name
    , CAST(tax_audit_status AS string)    AS tax_audit_status
    , CAST(ssc_audit_status AS int)       AS ssc_audit_status
    , CAST(tax_received_at AS timestamp)  AS tax_received_at
    , CAST(ssc_received_at AS timestamp)  AS ssc_received_at
    , CAST(diff_flag AS int)              AS diff_flag
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(source_notify_flag AS int)     AS source_notify_flag
FROM {{ source('source_knt', 'raw_report_comparison_header') }}