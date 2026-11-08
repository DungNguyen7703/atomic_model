/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_application_specializations
* Program name: ODS NHNCK.APPLICATION_SPECIALIZATIONS
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
    , application_id
    , specialization_id
    , issue_date
    , issue_place
    , status
    , note
    , assignee_id
    , appraisaled_at
    , created_by
    , created_at
    , updated_at
    , files
    , updated_by
FROM {{ ref('stg_nhnck_application_specializations') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')