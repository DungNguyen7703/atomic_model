/*
*--------------------------------------------------------------------*
* Program code: ods_fms_pension_fund
* Program name: ODS FMS.PENSION_FUND
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-10		tra		Them dieu kien loc ban ghi con hieu luc (theo ods_filters.pdf): deleted = 0
*--------------------------------------------------------------------*
*/

SELECT
    id
    , sec_id
    , business_cert_no
    , item_name
    , name_en
    , short_name
    , custodian_bank_id
    , supervisor_bank_id
    , status_id
    , note
    , file_name
    , file_data
    , deleted
    , date_created
    , created_by
    , date_modified
    , modify_by
FROM {{ ref('stg_fms_pension_fund') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0