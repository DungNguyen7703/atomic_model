/*
*--------------------------------------------------------------------*
* Program code: ods_scms_cat_company_type
* Program name: ODS SCMS.CAT_COMPANY_TYPE
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
    , company_type_code
    , company_type_name
    , note
    , created_by
    , created_at
    , record_status
    , joint_stock_company
    , ecatalog_id
FROM {{ ref('stg_scms_cat_company_type') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')