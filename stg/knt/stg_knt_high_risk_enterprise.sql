/*
*--------------------------------------------------------------------*
* Program code: stg_knt_high_risk_enterprise
* Program name: Staging KNT.HIGH_RISK_ENTERPRISE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: kieu int sang bigint (2 cot); them cot data_dt; yml snapshot/ds_snpst_dt -> append/data_dt theo BRD.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(enterprise_code AS string)        AS enterprise_code
    , CAST(enterprise_name AS string)        AS enterprise_name
    , CAST(hq_address AS string)             AS hq_address
    , CAST(managing_tax_authority AS string) AS managing_tax_authority
    , CAST(risk_assessment_year AS string)   AS risk_assessment_year
    , CAST(msg_packet_id AS bigint)          AS msg_packet_id
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AS data_dt
FROM {{ source('source_knt', 'raw_high_risk_enterprise') }}