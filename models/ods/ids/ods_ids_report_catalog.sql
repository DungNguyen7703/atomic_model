/*
*--------------------------------------------------------------------*
* Program code: ods_ids_report_catalog
* Program name: ODS IDS.REPORT_CATALOG
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
    , report_cd
    , report_name_vi
    , report_name_en
    , rc_type_cd
    , report_year
    , report_scope_cd
    , enterprise_type_cd
    , consolidated_flg
    , active_flg
    , is_deleted
    , created_by
    , created_date
    , updated_by
    , updated_date
    , financial_statement_cd
    , reporting_period_cd
    , ref_cd
FROM {{ ref('stg_ids_report_catalog') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')