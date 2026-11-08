/*
*--------------------------------------------------------------------*
* Program code: ods_fms_agency_type
* Program name: ODS FMS.AGENCY_TYPE
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-14		claude				Khởi tạo — nguồn cho Atomic cl_fms_agency_type
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , item_name
    , record_status
    , description
    , deleted
FROM {{ ref('stg_fms_agency_type') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0
    AND record_status = 1
