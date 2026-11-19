/*
*--------------------------------------------------------------------*
* Program code: ods_fms_pension_provider
* Program name: ODS FMS.PENSION_PROVIDER
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
    , eng_name
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
FROM {{ ref('stg_fms_pension_provider') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
  AND record_status = 1