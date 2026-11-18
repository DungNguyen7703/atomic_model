/*
*--------------------------------------------------------------------*
* Program code: ods_fms_company_type
* Program name: ODS FMS.COMPANY_TYPE
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khởi tạo — nguồn cho Atomic FMS (sync LLD Atomic FMS UAT 20261006)
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , item_name
    , description
    , record_status
    , system_object
    , joint_stock
    , deleted
    , data_migration
    , code
FROM {{ ref('stg_fms_company_type') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0
    AND record_status = 1