/*
*--------------------------------------------------------------------*
* Program code: stg_audit_company_digital_certificates
* Program name: Staging AUDIT.COMPANY_DIGITAL_CERTIFICATES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
* 2026-11-07		tuan.nguyenvanb		Dong bo theo AUDIT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang bigint (2 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                 AS id
    , CAST(company_profile_id AS bigint) AS company_profile_id
    , CAST(serial_no AS string)         AS serial_no
    , CAST(provider_name AS string)     AS provider_name
    , CAST(signature_type_cd AS string) AS signature_type_cd
    , CAST(start_date AS date)          AS start_date
    , CAST(end_date AS date)            AS end_date
    , CAST(active_flg AS int)           AS active_flg
    , CAST(created_by AS string)        AS created_by
    , CAST(created_date AS timestamp)    AS created_date
    , CAST(updated_by AS string)        AS updated_by
    , CAST(updated_date AS timestamp)    AS updated_date
    , CAST(delete_flg AS int)           AS delete_flg
FROM {{ source('source_audit', 'raw_company_digital_certificates') }}