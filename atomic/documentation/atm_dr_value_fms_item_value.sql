/*
*--------------------------------------------------------------------*
* Program code: atm_dr_value_fms_item_value
* Program name: Atomic Dynamic Report Value FMS.ITEM_VALUE
* Created by: claude (sync)
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		claude (sync)		Tạo mới theo dm_atm_dr_value-FMS.ITEM_VALUE.yaml (BK = item_id ‖ report_log_id ‖ row_order).
*                                       Tách khỏi atm_dr_value (nhiều nguồn: FMS + SCMS) thành model ephemeral theo nguồn.
*                                       Nguồn item_value ở ODS thực chất kéo từ FMS.RPT_VALUES (xem docs/rpt_values_stg_ods_atomic_strategy.md).
*                                       Chiến lược delta: ODS (đội khác xử lý) chỉ nạp delta, đánh dấu bằng cột data_dt = etl_date;
*                                       model này chỉ đọc partition data_dt = etl_date (không đọc full), khử trùng theo BK để
*                                       1 BK đúng 1 dòng (tránh MERGE cardinality violation) rồi đẩy sang atm_dr_value (merge).
*                                       Python ODS khử trùng có thêm acc_value: nếu 1 BK có nhiều acc_value thì ở đây chỉ giữ 1 dòng
*                                       (thứ tự phụ acc_value) — chờ Data Modeler xác nhận BK.
*--------------------------------------------------------------------*
*/

WITH it_va_raw AS (
    SELECT
        item_id
        , report_log_id
        , row_order
        , entity_code
        , is_label_col
        , value
        , acc_value
        , is_dynamic
        , kieu_dl
        , ngay_nop
        , row_number() OVER (
            PARTITION BY item_id, report_log_id, row_order
            ORDER BY `_loaded_at` DESC, acc_value DESC
        ) AS rn
    FROM {{ source('source_fms_bcd', 'raw_item_value') }}
    WHERE data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND item_id IS NOT NULL
        AND report_log_id IS NOT NULL
),

it_va AS (
    SELECT *
    FROM it_va_raw
    WHERE rn = 1
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_ITEM_VALUE', "concat_ws('-', item_id, report_log_id, row_order)") }}  AS dr_val_id
    , CAST(concat_ws('-', item_id, report_log_id, row_order) AS string)                                         AS dr_val_code
    , CAST('FMS_ITEM_VALUE' AS string)                                                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_ITEM_LIST', "item_id") }}                                           AS dr_structure_id
    , CAST(item_id AS string)                                                                                   AS dr_structure_code
    , {{ generate_surrogate_key_bigint('FMS_REPORT_HISTORY', "report_log_id") }}                                AS dr_submission_history_id
    , CAST(report_log_id AS string)                                                                             AS dr_submission_history_code
    , CAST(row_order AS int)                                                                                    AS row_dynamic_index
    , CAST(entity_code AS string)                                                                               AS entity_code
    , CAST(is_label_col AS int)                                                                                 AS label_column_ind
    , CAST(value AS string)                                                                                     AS val
    , CAST(acc_value AS string)                                                                                 AS custodian_bank_code
    , CAST(is_dynamic AS int)                                                                                   AS dynamic_ind
    , CAST(kieu_dl AS string)                                                                                   AS data_tp
    , CAST(ngay_nop AS date)                                                                                    AS submission_dt
FROM it_va
