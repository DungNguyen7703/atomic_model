/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_business_event_organization_type
* Program name: Staging ECAT.BUSINESS_EVENT_ORGANIZATION_TYPE
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(business_event_id AS string)        AS business_event_id
    , CAST(organization_type_id AS string)     AS organization_type_id
    , CAST(business_event_stable_id AS string) AS business_event_stable_id
FROM {{ source('source_ecat', 'raw_business_event_organization_type') }}