/*
*--------------------------------------------------------------------*
* Program code: atm_sc_report_input_value
* Program name: Atomic Securities Company Report Input Value
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*                                       Normalize numeric cell value
*--------------------------------------------------------------------*
*/

WITH re_in_ce_va AS (
    SELECT
        id
        , report_input_submission_id
        , sheet_id
        , section_id
        , cell_id
        , row_no
        , item_value
        , ref_type
    FROM {{ ref('ods_scms_report_input_cell_value') }}
    WHERE data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

/* B1: bỏ khoảng trắng (kể cả NBSP) */
, re_in_ce_va_cln AS (
    SELECT
        re_in_ce_va.*
        , regexp_replace(trim(CAST(re_in_ce_va.item_value AS string)), '[\\s\\u00A0]', '') AS val_cln
    FROM re_in_ce_va
)

/* B2: tách dấu | phần định trị | số mũ. Không khớp thì regexp_extract trả về '' */
, re_in_ce_va_prs AS (
    SELECT
        re_in_ce_va_cln.*
        , regexp_extract(val_cln, '^([+-]?)([0-9.,]+)([eE][+-]?[0-9]+)?$', 1) AS num_sign
        , regexp_extract(val_cln, '^([+-]?)([0-9.,]+)([eE][+-]?[0-9]+)?$', 2) AS num_mant
        , regexp_extract(val_cln, '^([+-]?)([0-9.,]+)([eE][+-]?[0-9]+)?$', 3) AS num_exp
    FROM re_in_ce_va_cln
)

/* B3: chuẩn hóa dấu phân cách và cast sang số */
, re_in_ce_va_num AS (
    SELECT
        re_in_ce_va_prs.*
        , TRY_CAST(
            concat(
                num_sign
                , CASE
                    -- 123456789
                    WHEN num_mant RLIKE '^[0-9]+$'
                        THEN num_mant
                    -- 1.5 | .5          (một dấu '.' => thập phân)
                    WHEN num_mant RLIKE '^[0-9]*[.][0-9]+$'
                        THEN num_mant
                    -- 123,456,789 | 123,456.789 | 1,234
                    WHEN num_mant RLIKE '^[0-9]{1,3}(,[0-9]{3})+([.][0-9]+)?$'
                        THEN replace(num_mant, ',', '')
                    -- 123.456.789 | 123.456,789
                    WHEN num_mant RLIKE '^[0-9]{1,3}([.][0-9]{3})+(,[0-9]+)?$'
                        THEN replace(replace(num_mant, '.', ''), ',', '.')
                    -- 1,5 | ,5          (một dấu ',' không theo nhóm 3 => thập phân)
                    WHEN num_mant RLIKE '^[0-9]*,[0-9]+$'
                        THEN replace(num_mant, ',', '.')
                  END
                , num_exp
            ) AS DECIMAL(38, 10)
          ) AS num_val
    FROM re_in_ce_va_prs
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_REPORT_INPUT_CELL_VALUE', "re_in_ce_va_num.id") }}                           AS sc_rpt_input_val_id
    , CAST(re_in_ce_va_num.id AS string)                                                                                AS sc_rpt_input_val_code
    , CAST('SCMS_REPORT_INPUT_CELL_VALUE' AS string)                                                                    AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_REPORT_INPUT_SUBMISSION', "re_in_ce_va_num.report_input_submission_id") }} AS sc_rpt_input_submission_id
    , CAST(re_in_ce_va_num.report_input_submission_id AS string)                                                        AS sc_rpt_input_submission_code
    , CAST(re_in_ce_va_num.sheet_id AS string)                                                                          AS sheet_id
    , CAST(re_in_ce_va_num.section_id AS string)                                                                        AS section_id
    , CAST(re_in_ce_va_num.cell_id AS string)                                                                           AS cell_id
    , CAST(re_in_ce_va_num.row_no AS int)                                                                               AS row_index
    , CASE
        WHEN re_in_ce_va_num.num_val IS NOT NULL
            -- format_number: plain string, không bị scientific; sau đó bỏ ',' và các số 0 thừa
            THEN regexp_replace(
                    regexp_replace(
                        regexp_replace(format_number(re_in_ce_va_num.num_val, 10), ',', '')
                    , '0+$', '')
                 , '[.]$', '')
        ELSE CAST(re_in_ce_va_num.item_value AS string)
      END                                                                                                               AS cell_val
    , re_in_ce_va_num.num_val                                                                                           AS cell_num_val
    , CAST(re_in_ce_va_num.ref_type AS string)                                                                          AS ref_tp_code
FROM re_in_ce_va_num