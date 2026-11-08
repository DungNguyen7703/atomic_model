/*
*--------------------------------------------------------------------*
* Program code: stg_scms_report_input_cell_value
* Program name: Staging SCMS.REPORT_INPUT_CELL_VALUE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-24		tuan.nguyenvanb		Them cot ref_type (LLD lld_SCMS_REPORT_INPUT
*									_CELL_VALUE.yaml: attribute Ref Type Code,
*									phat sinh moi o nguon UAT 2026-09-15) - phuc
*									vu atm_sc_report_input_value.ref_tp_code.
* 2026-10-07		tuan.nguyenvanb		Bang nguon khoang 64 trieu dong: them hint REPARTITION(64)
*									de ghi STG ra nhieu file deu (ODS doc song song). Hint chi
*									tac dung sau buoc doc Oracle, khong tang toc do doc JDBC.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                           AS id
    , CAST(report_input_submission_id AS decimal(19,0)) AS report_input_submission_id
    , CAST(sheet_id AS string)                          AS sheet_id
    , CAST(section_id AS string)                        AS section_id
    , CAST(cell_id AS string)                           AS cell_id
    , CAST(row_no AS bigint)                            AS row_no
    , CAST(item_value AS string)                        AS item_value
    , CAST(period_year AS int)                          AS period_year
    , CAST(ref_type AS string)                          AS ref_type
    , to_date('{{ var("etl_date") }}','yyyy-MM-dd') 							AS data_dt
FROM
	{{ source('source_scms', 'raw_report_input_cell_value') }}    
WHERE
	REPORT_INPUT_SUBMISSION_id IN (
	SELECT
		id
	FROM
		{{ source('source_scms', 'raw_report_input_submission') }} 
	WHERE
		(date_format(CREATED_AT, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
			AND date_format(CREATED_AT, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}','yyyy-MM-dd') + 1)
			OR (date_format(LAST_MODIFIED_AT,'yyyy-MM-dd')  >= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
				AND (date_format(LAST_MODIFIED_AT,'yyyy-MM-dd') < to_date('{{ var("etl_date") }}','yyyy-MM-dd') + 1)))