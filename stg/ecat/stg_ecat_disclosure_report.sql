/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_disclosure_report
* Program name: Staging ECAT.DISCLOSURE_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang string (2 cot); them cot obligation_type, legal_basis, fund_type_name, agent_type_name, rpt_input_form_name, eform_cbtt_form_name, deadline_calc_method, direction, amount, unit, id_sync, is_sync, module_code; bo cot report_period, form_legal_basis, submission_time, disclosure_deadline.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(code AS string)                    AS code
    , CAST(name AS string)                    AS name
    , CAST(report_status AS int)              AS report_status
    , CAST(deleted AS int)                    AS deleted
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(stable_id AS string)               AS stable_id
    , CAST(version AS int)                    AS version
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(old_id AS string)                  AS old_id
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(report_type AS string)             AS report_type
    , CAST(obligation_type AS string)         AS obligation_type
    , CAST(legal_basis AS string)             AS legal_basis
    , CAST(fund_type_name AS string)          AS fund_type_name
    , CAST(agent_type_name AS string)         AS agent_type_name
    , CAST(rpt_input_form_name AS string)     AS rpt_input_form_name
    , CAST(eform_cbtt_form_name AS string)    AS eform_cbtt_form_name
    , CAST(deadline_calc_method AS string)    AS deadline_calc_method
    , CAST(direction AS string)               AS direction
    , CAST(amount AS bigint)                  AS amount
    , CAST(unit AS int)                       AS unit
    , CAST(id_sync AS string)                 AS id_sync
    , CAST(is_sync AS int)                    AS is_sync
    , CAST(module_code AS string)             AS module_code
    , CAST(applied_subject AS string)         AS applied_subject
FROM {{ source('source_ecat', 'raw_disclosure_report') }}