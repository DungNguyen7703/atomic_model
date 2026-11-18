/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_insider_relation
* Program name: ODS SCMS.SC_FIRM_INSIDER_RELATION
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
    , sc_firm_info_id
    , senior_personnel_id
    , full_name
    , national_id
    , relationship
    , ownership_ratio
    , record_status
    , created_at
    , created_by
    , founding_shareholder
    , permanent_address
    , phone
    , email
    , note
    , gender
    , relation_start_date
    , issue_date
    , last_modified_at
    , ownership_ratio_date
    , date_of_birth
    , issue_place
    , nationality_id
    , shares_count
    , last_modified_by
    , entity_type
    , name_en
    , short_name
    , legal_representative_name
    , representative_position
    , deleted
FROM {{ ref('stg_scms_sc_firm_insider_relation') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')