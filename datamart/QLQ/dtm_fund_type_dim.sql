/*
*--------------------------------------------------------------------*
* Program code: dtm_fund_type_dim
* Program name: Dtm Fund Type Dim
* Created by:
* Created date: 2026-10-10
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-10		claude				Khởi tạo: Dim loại hình quỹ từ atm_cl_fms_fund_type (Atomic promote scheme FMS_FUND_TYPE
*                                       khỏi cl_value -> dtm_cl_dim không còn dữ liệu FMS_FUND_TYPE). Pattern theo dtm_service_tp_dim.
*                                       fund_type_id = hash('FMS_FUND_TYPE', cl_fms_fund_tp_code) (trùng SK Atomic cl_fms_fund_tp_id) — CHƯA có LLD Datamart
*--------------------------------------------------------------------*
*/

WITH cl_fund_type AS (
    SELECT
        cl_fms_fund_tp_id,
        cl_fms_fund_tp_code,
        cl_fms_fund_tp_nm,
        description,
        open_fund_ind,
        src_stm_code
    FROM {{ ref('atm_cl_fms_fund_type') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUND_TYPE'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('FMS_FUND_TYPE', 'cl_fms_fund_tp_code') }} AS string)  AS fund_type_id,
    CAST(cl_fms_fund_tp_code AS string)                                                          AS fund_type_code,
    CAST(cl_fms_fund_tp_nm AS string)                                                            AS fund_type_nm,
    CAST(open_fund_ind AS int)                                                                   AS open_fund_indicator,
    CAST(src_stm_code AS string)                                                                 AS src_stm_code
FROM cl_fund_type
