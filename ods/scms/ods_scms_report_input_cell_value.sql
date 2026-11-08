/*
*--------------------------------------------------------------------*
* Program code: ods_scms_report_input_cell_value
* Program name: ODS SCMS.REPORT_INPUT_CELL_VALUE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-24		tuan.nguyenvanb		Tao moi theo LLD lld_SCMS_REPORT_INPUT_CELL_VALUE.yaml
*									(atomic_entity: Securities Company Report Input
*									Value) - phuc vu gap O_PTTT_13/O_PTTT_16
*									(margin/VCSH CTCK cho fct_market_risk_snpst,
*									fct_mbr_sfty_per_mbr_snpst).
* 2026-10-07		tuan.nguyenvanb		Bang khoang 64 trieu dong: them hint REPARTITION(64) de
*									kiem soat so file ghi ra va song song hoa buoc ghi ODS.
*--------------------------------------------------------------------*
*/

SELECT /*+ REPARTITION(64) */
    id
    , report_input_submission_id
    , sheet_id
    , section_id
    , cell_id
    , row_no
    , item_value
    , ref_type
    , data_dt
FROM {{ ref('stg_scms_report_input_cell_value') }}
WHERE data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
