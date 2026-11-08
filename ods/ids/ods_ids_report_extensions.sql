/*
*--------------------------------------------------------------------*
* Program code: ods_ids_report_extensions
* Program name: ODS IDS.REPORT_EXTENSIONS
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
    , company_profile_id
    , form_cd
    , report_period
    , extension_days
    , doc_no
    , doc_date
    , report_year
    , report_quarter
    , created_by
    , created_date
    , updated_by
    , updated_date
FROM {{ ref('stg_ids_report_extensions') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')