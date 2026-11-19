/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_admin_sanction
* Program name: ODS SCMS.SC_FIRM_ADMIN_SANCTION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-10		tra		Them dieu kien loc ban ghi con hieu luc (theo ods_filters.pdf): record_status = 1
*--------------------------------------------------------------------*
*/

SELECT
    id
    , sc_firm_info_id
    , form_type
    , content
    , amount
    , additional_penalty
    , additional_penalty_date
    , decision_content
    , decision_date
    , created_by
    , created_at
    , last_modified_by
    , last_modified_at
    , record_status
    , attachment_path
    , processing_unit
    , remedial_measure
FROM {{ ref('stg_scms_sc_firm_admin_sanction') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND record_status = 1