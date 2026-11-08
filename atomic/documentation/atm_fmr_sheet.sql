/*
*--------------------------------------------------------------------*
* Program code: atm_fmr_sheet
* Program name: Atomic Fund Management Report Sheet
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khoi tao theo LLD Atomic FMS UAT 20261006 (lld_FMS_SHEET.yaml)
* 2026-10-12		claude				Grain theo cell: key = id + row_index + column_index, them 6 cot cell tu ODS
*--------------------------------------------------------------------*
*/

WITH sh AS (
    SELECT
        id,
        rpt_id,
        item_name,
        sheet_index,
        description,
        investment_portfolio,
        row_index,
        column_index,
        cell_id,
        label_nm,
        row_span,
        column_span,
        code
    FROM {{ ref('ods_fms_sheet') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_SHEET', "concat_ws('|', id, row_index, column_index)") }}       AS fmr_sheet_id,
    CAST(id AS string)                                                                                    AS fmr_sheet_code,
    CAST('FMS_SHEET' AS string)                                                                           AS src_stm_code,
    {{ generate_surrogate_key_bigint('FMS_RPT_TEMP', "rpt_id") }}                                         AS fmr_id,
    CAST(rpt_id AS string)                                                                                AS fmr_code,
    CAST(item_name AS string)                                                                             AS fmr_sheet_nm,
    CAST(sheet_index AS int)                                                                              AS sheet_index,
    CAST(description AS string)                                                                           AS description,
    CAST(investment_portfolio AS int)                                                                     AS investment_portfolio_ind,
    CAST(row_index AS int)                                                                                AS row_index,
    CAST(column_index AS int)                                                                             AS column_index,
    CAST(cell_id AS string)                                                                               AS cell_id,
    CAST(label_nm AS string)                                                                              AS label_nm,
    CAST(row_span AS int)                                                                                 AS row_span,
    CAST(column_span AS int)                                                                              AS column_span,
    CAST(code AS string)                                                                                  AS sheet_short_code
FROM sh