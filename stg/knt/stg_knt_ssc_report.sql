/*
*--------------------------------------------------------------------*
* Program code: stg_knt_ssc_report
* Program name: Staging KNT.SSC_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: WHERE loc theo BRD filter_logic; kieu int sang bigint (2 cot); kieu date sang timestamp (3 cot); kieu int sang decimal(38,10) (1 cot); yml snapshot/ds_snpst_dt -> append/created_at theo BRD.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(system_code AS int)              AS system_code
    , CAST(report_code AS string)           AS report_code
    , CAST(report_name AS string)           AS report_name
    , CAST(org_unit_code AS string)         AS org_unit_code
    , CAST(report_type AS int)              AS report_type
    , CAST(period_type AS string)           AS period_type
    , CAST(report_period AS string)         AS report_period
    , CAST(period_from_date AS string)      AS period_from_date
    , CAST(period_to_date AS string)        AS period_to_date
    , CAST(period_from_month AS string)     AS period_from_month
    , CAST(period_to_month AS string)       AS period_to_month
    , CAST(sent_at AS timestamp)             AS sent_at
    , CAST(audit_status AS int)             AS audit_status
    , CAST(audit_firm_name AS string)       AS audit_firm_name
    , CAST(audit_firm_tax_code AS string)   AS audit_firm_tax_code
    , CAST(business_reg_cert AS string)     AS business_reg_cert
    , CAST(audit_opinion_code AS string)    AS audit_opinion_code
    , CAST(audit_opinion AS string)         AS audit_opinion
    , CAST(audit_date AS date)              AS audit_date
    , CAST(auditor_name AS string)          AS auditor_name
    , CAST(extension_reason_code AS string) AS extension_reason_code
    , CAST(extension_reason AS string)      AS extension_reason
    , CAST(signatory AS string)             AS signatory
    , CAST(signed_at AS timestamp)           AS signed_at
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(msg_packet_id AS bigint)          AS msg_packet_id
    , CAST(enterprise_code AS string)       AS enterprise_code
    , CAST(guid AS string)                  AS guid
    , CAST(tax_code AS string)              AS tax_code
    , CAST(report_source_url AS string)     AS report_source_url
    , CAST(practice_cert_number AS string)  AS practice_cert_number
    , CAST(going_concern_yes AS string)     AS going_concern_yes
    , CAST(going_concern_no AS string)      AS going_concern_no
    , CAST(declaration_code AS string)      AS declaration_code
    , CAST(is_latest AS int)                AS is_latest
    , CAST(has_diff AS int)                 AS has_diff
    , CAST(peer_report_id AS decimal(38,10)) AS peer_report_id
    , CAST(dc_ready AS int)                 AS dc_ready
FROM {{ source('source_knt', 'raw_ssc_report') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1