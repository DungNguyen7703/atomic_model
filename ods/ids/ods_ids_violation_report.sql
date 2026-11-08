/*
*--------------------------------------------------------------------*
* Program code: ods_ids_violation_report
* Program name: ODS IDS.VIOLATION_REPORT
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
    , violation_template_id
    , form_id
    , form_cd
    , period_name
    , period_quarter
    , period_year
    , base_column
    , base_date
    , deadline_date
    , actual_submit_date
    , status
    , created_date
    , created_by
    , updated_date
    , updated_by
    , original_deadline
    , language_cd
FROM {{ ref('stg_ids_violation_report') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')