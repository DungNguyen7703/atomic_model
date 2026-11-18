/*
*--------------------------------------------------------------------*
* Program code: stg_knt_audit_firm
* Program name: Staging KNT.AUDIT_FIRM
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: WHERE loc theo BRD filter_logic; kieu int sang bigint (2 cot); kieu date sang timestamp (1 cot); yml snapshot/ds_snpst_dt -> append/decision_date theo BRD.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(decision_number AS string)        AS decision_number
    , CAST(decision_date AS timestamp)       AS decision_date
    , CAST(name AS string)                   AS name
    , CAST(address AS string)                AS address
    , CAST(phone AS string)                  AS phone
    , CAST(fax AS string)                    AS fax
    , CAST(approval_year AS string)          AS approval_year
    , CAST(approved_auditor_count AS string) AS approved_auditor_count
    , CAST(tax_code AS string)               AS tax_code
    , CAST(msg_packet_id AS bigint)          AS msg_packet_id
    , CAST(business_reg_cert AS string)      AS business_reg_cert
    , CAST(guid AS string)                   AS guid
FROM {{ source('source_knt', 'raw_audit_firm') }}
WHERE date_format(decision_date, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(decision_date, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1