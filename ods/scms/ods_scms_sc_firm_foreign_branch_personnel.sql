/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_foreign_branch_personnel
* Program name: ODS SCMS.SC_FIRM_FOREIGN_BRANCH_PERSONNEL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Dong bo day du cot theo stg moi.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , business_division
    , national_id
    , position_json
    , securities_license
    , sc_firm_foreign_branch_id
    , disclosure_representative
    , address
    , permanent_address
    , phone
    , email
    , disclosure_email
    , attachment_path
    , note
    , gender
    , full_name
    , work_start_date
    , appointment_date
    , securities_license_date
    , id_issued_date
    , dismissal_date
    , resignation_date
    , date_of_birth
    , created_at
    , branch_head_user_id
    , issue_place
    , department
    , nationality
    , securities_license_number
    , record_status
    , work_status
    , verification_status
    , created_by
    , last_modified_by
    , last_modified_at
    , deleted
FROM {{ ref('stg_scms_sc_firm_foreign_branch_personnel') }}
WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1