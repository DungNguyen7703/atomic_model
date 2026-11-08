/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_related_person
* Program name: ODS SCMS.SC_FIRM_RELATED_PERSON
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
    , entity_type
    , full_name
    , identification_number
    , relationship
    , ownership_ratio
    , record_status
    , created_at
    , representative_title
    , position_id
    , founding_shareholder
    , permanent_address
    , phone
    , workplace
    , email
    , note
    , gender
    , appointment_date
    , issue_date
    , last_modified_at
    , ownership_ratio_date
    , date_of_birth
    , legal_representative
    , created_by
    , issue_place
    , country_id
    , shares_count
    , org_name_en
    , org_short_name
    , transaction_time
    , resolution_number
    , transaction_content
    , relation_start_date
    , relation_end_date
    , deleted
FROM {{ ref('stg_scms_sc_firm_related_person') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')