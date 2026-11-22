/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_dynamic_report_val
* Program name: Datamart Fact Dynamic Report Value
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH dr_value AS (
    SELECT
        dr_val_id,
        dr_structure_id,
        dr_submission_history_id,
        submission_dt,
        dr_structure_code,
        dr_submission_history_code,
        row_dynamic_index,
        entity_code,
        label_column_ind,
        val,
        custodian_bank_code,
        dynamic_ind,
        data_tp,
        src_stm_code
    FROM {{ ref('atm_dr_value') }}
    WHERE src_stm_code = 'FMS_ITEM_VALUE'
        AND data_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
)

SELECT
    CAST(dr_val_id AS string)                                  AS dr_val_id,
    CAST(dr_structure_id AS string)                            AS dr_structure_id,
    CAST(dr_submission_history_id AS string)                   AS dr_submission_history_id,
    date_format(submission_dt, 'yyyyMMdd')                     AS submission_dt_dim_id,
    CAST(dr_structure_code AS string)                          AS dr_structure_code,
    CAST(dr_submission_history_code AS string)                 AS dr_submission_history_code,
    CAST(row_dynamic_index AS int)                             AS row_dynamic_index,
    CAST(entity_code AS string)                                AS entity_code,
    CAST(label_column_ind AS int)                              AS label_column_ind,
    CAST(val AS string)                                        AS val,
    CAST(custodian_bank_code AS string)                        AS custodian_bank_code,
    CAST(dynamic_ind AS int)                                   AS dynamic_ind,
    CAST(data_tp AS string)                                    AS data_tp,
    CAST(src_stm_code AS string)                               AS src_stm_code
FROM dr_value
