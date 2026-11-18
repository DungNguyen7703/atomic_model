/*
*--------------------------------------------------------------------*
* Program code: stg_ids_company_digital_certificates
* Program name: Staging IDS.COMPANY_DIGITAL_CERTIFICATES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(company_profile_id AS int)   AS company_profile_id
    , CAST(serial_no AS string)         AS serial_no
    , CAST(provider_name AS string)     AS provider_name
    , CAST(signature_type_cd AS string) AS signature_type_cd
    , CAST(start_date AS date)          AS start_date
    , CAST(end_date AS date)            AS end_date
    , CAST(active_flg AS int)           AS active_flg
    , CAST(created_by AS string)        AS created_by
    , CAST(created_date AS date)        AS created_date
    , CAST(updated_by AS string)        AS updated_by
    , CAST(updated_date AS date)        AS updated_date
    , CAST(delete_flg AS int)           AS delete_flg
    , CAST(system_cd AS string)         AS system_cd
FROM {{ source('source_ids', 'raw_company_digital_certificates') }}