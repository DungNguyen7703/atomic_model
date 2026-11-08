/*
*--------------------------------------------------------------------*
* Program code: ods_ids_pub_company_cancellation
* Program name: ODS IDS.PUB_COMPANY_CANCELLATION
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
    , cancel_type_cd
    , cancellation_date
    , application_submission_date
    , eligibility_date_after_cancellation
    , approval_status_cd
    , decision_no
    , decision_date
    , created_date
    , created_by
    , updated_date
    , updated_by
    , delete_flg
    , official_letter_no
    , official_letter_date
FROM {{ ref('stg_ids_pub_company_cancellation') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')