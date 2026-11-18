/*
*--------------------------------------------------------------------*
* Program code: ods_fms_rpt_member
* Program name: ODS FMS.RPT_ME  MBER
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-14		claude				Khởi tạo — nguồn cho Atomic fmr_submission
* 2026-10-20        Duc                 Bỏ lọc record_status vì cột là cột nghiệp vụ,
                                        không mang ý nghĩa cờ hiệu lực bản ghi.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , prd_id
    , rpt_name
    , report_type
    , record_status
    , imported
    , date_submitted
    , file_data
    , content_summary
    , note
    , bkm_id
    , fnd_id
    , fr_br_id
    , sec_id
    , record_type
    , file_import
    , day_report
    , period_value
    , year_value
    , rpt_id
    , deleted
    , id_db_old
    , period_type
    , distributor_id
    , transfer_agent_id
    , pension_agent_id
    , pension_provider_id
    , other_agent_id
    , pension_fund_id
    , member_name
    , approval_action
    , event_type_id
    , deadline_send
    , eform_data_json
    , audit_firm_id
    , auditor_id
    , cbtt_date
FROM {{ ref('stg_fms_rpt_member') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0
