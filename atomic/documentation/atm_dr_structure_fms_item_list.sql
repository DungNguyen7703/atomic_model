/*
*--------------------------------------------------------------------*
* Program code: atm_dr_structure_fms_item_list
* Program name: Atomic Dynamic Report Structure FMS.ITEM_LIST
* Created by: claude (sync)
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		claude (sync)		Tách từ atm_dr_structure thành model ephemeral theo nguồn (BK = item_id); thêm cột riêng SCMS = NULL để UNION ALL.
*                                       Nguồn ODS FMS do Python DAG ghi (append) -> đọc TOÀN BỘ bảng, giữ bản _loaded_at mới nhất mỗi item_id
*                                       (mcr_scd2 đóng các key vắng mặt trong input nên union phải chứa đủ mọi nguồn).
*--------------------------------------------------------------------*
*/

WITH it_li AS (
    SELECT
        item_id
        , report_code
        , report_name
        , sheet_name
        , column_path
        , row_path
        , uid_cell
        , `_row`
        , `_col`
        , legal_basis
        , is_label_col
        , label_item_id
    FROM {{ source('source_fms_bcd', 'raw_item_list') }}
    WHERE item_id IS NOT NULL
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_ITEM_LIST', "item_id") }}   AS dr_structure_id
    , CAST(item_id AS string)                                         AS dr_structure_code
    , CAST('FMS_ITEM_LIST' AS string)                                 AS src_stm_code
    , CAST(report_code AS string)                                     AS rpt_code
    , CAST(report_name AS string)                                     AS rpt_nm
    , CAST(sheet_name AS string)                                      AS sheet_nm
    , CAST(column_path AS string)                                     AS column_path
    , CAST(row_path AS string)                                        AS row_path
    , CAST(uid_cell AS string)                                        AS cell_id
    , CAST(`_row` AS int)                                             AS row_index
    , CAST(`_col` AS int)                                             AS column_index
    , CAST(legal_basis AS string)                                     AS legal_basis
    , CAST(is_label_col AS int)                                       AS label_column_ind
    , CAST(label_item_id AS string)                                   AS dynamic_label_row
    , CAST(NULL AS string)                                            AS form_rpt_code
    , CAST(NULL AS int)                                               AS rpt_version
    , CAST(NULL AS int)                                               AS dynamic_ind
    , CAST(NULL AS string)                                            AS data_tp
    , CAST(NULL AS int)                                               AS active_ind
FROM it_li
