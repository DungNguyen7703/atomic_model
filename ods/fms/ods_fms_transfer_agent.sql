/*
*--------------------------------------------------------------------*
* Program code: ods_fms_transfer_agent
* Program name: ODS FMS.TRANSFER_AGENT
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
    , agent_type
    , company_type
    , item_name
    , name_en
    , short_name
    , business_license_no
    , license_issue_date
    , license_issued_by
    , tax_code
    , address
    , phone
    , fax
    , record_status
    , termination_date
    , deleted
    , date_created
    , created_by
    , date_modified
    , modify_by
    , status_id
FROM {{ ref('stg_fms_transfer_agent') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
  AND record_status = 1