/*
*--------------------------------------------------------------------*
* Program code: ods_fms_bank_employ
* Program name: ODS FMS.BANK_EMPLOY
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
    , bank_id
    , item_name
    , id_no
    , id_date
    , cert_no
    , cert_law
    , cert_audit
    , cert_date
    , record_status
    , deleted
    , position
    , data_migration
FROM {{ ref('stg_fms_bank_employ') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
  AND record_status = 1