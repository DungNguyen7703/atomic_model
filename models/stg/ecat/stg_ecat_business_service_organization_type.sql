/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_business_service_organization_type
* Program name: Staging ECAT.BUSINESS_SERVICE_ORGANIZATION_TYPE
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(business_service_id AS string)  AS business_service_id
    , CAST(organization_type_id AS string) AS organization_type_id
FROM {{ source('source_ecat', 'raw_business_service_organization_type') }}