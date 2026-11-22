/*
*--------------------------------------------------------------------*
* Program code: ods_fms_relation
* Program name: ODS FMS.RELATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-10		tra		Them dieu kien loc ban ghi con hieu luc (theo ods_filters.pdf): deleted = 0 AND record_status = 1
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
    , personal_type
    , record_status
    , deleted
    , data_migration
FROM {{ ref('stg_fms_relation') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
  AND record_status = 1