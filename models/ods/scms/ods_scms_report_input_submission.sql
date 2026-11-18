/*
*--------------------------------------------------------------------*
* Program code: ods_scms_report_input_submission
* Program name: ODS SCMS.REPORT_INPUT_SUBMISSION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-24		tuan.nguyenvanb		Tao moi theo LLD lld_SCMS_REPORT_INPUT_SUBMISSION.yaml
*									(atomic_entity: Securities Company Report Input
*									Submission) - phuc vu gap O_PTTT_13/O_PTTT_16
*									(margin/VCSH CTCK cho fct_market_risk_snpst,
*									fct_mbr_sfty_per_mbr_snpst).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , ref_type
    , ref_id
    , form_report_id
    , form_version_id
    , created_at
    , last_modified_at
    , period_year
FROM {{ ref('stg_scms_report_input_submission') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
