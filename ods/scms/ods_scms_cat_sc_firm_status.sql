/*
*--------------------------------------------------------------------*
* Program code: ods_scms_cat_sc_firm_status
* Program name: ODS SCMS.CAT_SC_FIRM_STATUS
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
    , sc_firm_status_code
    , sc_firm_status_name
    , note
    , created_by
    , report_submission_enabled
    , disclosure_enabled
    , created_at
    , record_status
    , active
    , code
    , item_name
    , applicable_entity
    , description
FROM {{ ref('stg_scms_cat_sc_firm_status') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')