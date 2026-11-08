/*
*--------------------------------------------------------------------*
* Program code: ods_ids_rep_forms
* Program name: ODS IDS.REP_FORMS
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
    , rp_report_type_cd
    , published_flg
    , report_link
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , system_cd
FROM {{ ref('stg_ids_rep_forms') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')