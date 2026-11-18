/*
*--------------------------------------------------------------------*
* Program code: ods_fms_distributor_agent
* Program name: ODS FMS.DISTRIBUTOR_AGENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
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
    , tax_code
    , license_issue_date
    , license_issued_by
    , distribution_cert_no
    , distribution_cert_date
    , distribution_cert_issued_by
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
    , distribution_digital_info
    , status_id
FROM {{ ref('stg_fms_distributor_agent') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0
    AND record_status = 1