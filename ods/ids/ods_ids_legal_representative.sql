/*
*--------------------------------------------------------------------*
* Program code: ods_ids_legal_representative
* Program name: ODS IDS.LEGAL_REPRESENTATIVE
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
    , name
    , position_cd
    , appointment_date
    , phone_no
    , email
    , identity_no
    , issue_date
    , issue_place
    , representative_role
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
FROM {{ ref('stg_ids_legal_representative') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')