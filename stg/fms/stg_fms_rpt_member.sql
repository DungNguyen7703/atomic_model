/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rpt_member
* Program name: Staging FMS.RPT_MEMBER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , CAST(date_created AS date)         AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS date)        AS date_modified
    , CAST(modify_by AS string)          AS modify_by
    , HEX(prd_id)                        AS prd_id
    , CAST(rpt_name AS string)           AS rpt_name
    , CAST(report_type AS decimal(18,2)) AS report_type
    , CAST(record_status AS bigint)      AS record_status
    , CAST(imported AS int)              AS imported
    , CAST(date_submitted AS date)       AS date_submitted
    , CAST(file_data AS string)          AS file_data          -- NCLOB: du lieu file dinh kem, khong dung cho BI, de NULL tranh nang
    , CAST(content_summary AS string)    AS content_summary
    , CAST(note AS string)               AS note
    , HEX(bkm_id)                        AS bkm_id
    , HEX(fnd_id)                        AS fnd_id
    , HEX(fr_br_id)                      AS fr_br_id
    , HEX(sec_id)                        AS sec_id
    , CAST(record_type AS decimal(38,0)) AS record_type
    , CAST(file_import AS string)        AS file_import        -- NCLOB: du lieu file import bao cao, khong dung cho BI, de NULL tranh nang
    , CAST(day_report AS date)           AS day_report
    , CAST(period_value AS string)       AS period_value
    , CAST(year_value AS decimal(18,2))  AS year_value
    , HEX(rpt_id)                        AS rpt_id
    , CAST(deleted AS int)               AS deleted
    , CAST(id_db_old AS string)          AS id_db_old
    , CAST(period_type AS decimal(38,0)) AS period_type
    , HEX(distributor_id)                AS distributor_id
    , HEX(transfer_agent_id)             AS transfer_agent_id
    , HEX(pension_agent_id)              AS pension_agent_id
    , HEX(pension_provider_id)           AS pension_provider_id
    , HEX(other_agent_id)                AS other_agent_id
    , HEX(pension_fund_id)               AS pension_fund_id
    , CAST(member_name AS string)        AS member_name
    , CAST(approval_action AS int)       AS approval_action
    , HEX(event_type_id)                 AS event_type_id
    , CAST(deadline_send AS timestamp)   AS deadline_send
    , CAST(eform_data_json AS string)    AS eform_data_json    -- CLOB JSON eform, du lieu lon, khong dung cho BI, de NULL
    , HEX(audit_firm_id)                 AS audit_firm_id
    , HEX(auditor_id)                    AS auditor_id
    , CAST(cbtt_date AS date)            AS cbtt_date
FROM {{ source('source_fms', 'raw_rpt_member') }}