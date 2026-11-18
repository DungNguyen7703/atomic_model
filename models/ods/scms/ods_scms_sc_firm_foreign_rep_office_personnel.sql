/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_foreign_rep_office_personnel
* Program name: ODS SCMS.SC_FIRM_FOREIGN_REP_OFFICE_PERSONNEL
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
    , sc_firm_foreign_rep_office_id
    , full_name
    , national_id
    , id_issued_date
    , issue_place
    , permanent_address
    , nationality
    , email
    , phone
    , position_json
    , rep_office_representative
    , appointment_date
    , dismissal_date
    , record_status
    , attachment_path
    , note
    , created_by
    , created_at
    , last_modified_by
    , last_modified_at
    , date_of_birth
    , deleted
FROM {{ ref('stg_scms_sc_firm_foreign_rep_office_personnel') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')