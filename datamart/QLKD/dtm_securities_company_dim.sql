/*
*--------------------------------------------------------------------*
* Program code: dtm_securities_company_dim
* Program name: Dtm Securities Company Dim
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-15		claude			[FIX] Theo LLD (DTM_QLKD_securities_
*                                       company_dim_SCMS_SC_FIRM_INFO.csv):
*                                       bo sung cot company_tp_nm - LEFT JOIN
*                                       cl_value ON schema_code =
*                                       'SCMS_COMPANY_TYPE' AND cl_code =
*                                       company_tp_code -> cl_nm. Co the NULL
*                                       neu Atomic chua nap values cho scheme
*                                       nay (dung nhu LLD tu ghi chu).
*--------------------------------------------------------------------*
*/

WITH se_co AS (
    SELECT
        sc_id,
        sc_code,
        sc_nm,
        sc_short_nm,
        company_tp_code,
        cl_sc_firm_status_id,
        listed_ind,
        exchange_code,
        src_stm_code
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
),

cl_sc_fi_st AS (
    SELECT
        cl_sc_firm_status_id,
        item_code
    FROM {{ ref('atm_cl_securities_company_firm_status') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_CAT_SC_FIRM_STATUS'
),

cl_val_co_tp AS (
    SELECT
        cl_code,
        cl_nm
    FROM atomic.uat_atm.cl_value
    WHERE schema_code = 'SCMS_COMPANY_TYPE'
        AND cl_code = 'CTCK'
        AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "CONCAT(sc_id, '|', sc_code)") }} AS string) AS securities_company_dim_id,
    CAST(se_co.sc_id AS string)                                              AS sc_id,
    CAST(se_co.sc_code AS string)                                            AS sc_code,
    CAST(se_co.sc_nm AS string)                                              AS sc_nm,
    CAST(se_co.sc_short_nm AS string)                                        AS sc_short_nm,
    CAST('CTCK' AS string)                                                   AS company_tp_code,
    CAST(cl_val_co_tp.cl_nm AS string)                                       AS company_tp_nm,
    CAST(
        CASE
            WHEN cl_sc_fi_st.item_code IS NULL  THEN NULL
            WHEN cl_sc_fi_st.item_code = 'B'     THEN 'REVOKED'
            WHEN cl_sc_fi_st.item_code = 'A'     THEN 'ACTIVE'
            WHEN cl_sc_fi_st.item_code = 'I'     THEN 'SPECIAL_CONTROLLED'
            WHEN cl_sc_fi_st.item_code = 'KS'    THEN 'CONTROLLED'
            WHEN cl_sc_fi_st.item_code = 'CB'    THEN 'WARNING'
            WHEN cl_sc_fi_st.item_code = 'S'     THEN 'SUSPENDED'
            ELSE 'OTHER'
        END AS string)                                                       AS company_status_code,
    CAST(
        CASE
            WHEN cl_sc_fi_st.item_code IS NULL  THEN NULL
            WHEN cl_sc_fi_st.item_code = 'B'     THEN 'Đã bị thu hồi'
            WHEN cl_sc_fi_st.item_code = 'A'     THEN 'Hoạt động bình thường'
            WHEN cl_sc_fi_st.item_code = 'I'     THEN 'Kiểm soát đặc biệt'
            WHEN cl_sc_fi_st.item_code = 'KS'    THEN 'Kiểm soát'
            WHEN cl_sc_fi_st.item_code = 'CB'    THEN 'Cảnh báo'
            WHEN cl_sc_fi_st.item_code = 'S'     THEN 'Đình chỉ hoạt động'
            ELSE 'Trạng thái khác'
        END AS string)                                                       AS company_status_nm,
    CAST(se_co.listed_ind AS boolean)                                        AS is_listed_indicator,
    CAST(se_co.exchange_code AS string)                                      AS stock_exchange_nm,
    CAST(se_co.src_stm_code AS string)                                       AS src_stm_code
FROM se_co
LEFT JOIN cl_sc_fi_st
    ON  cl_sc_fi_st.cl_sc_firm_status_id = se_co.cl_sc_firm_status_id
LEFT JOIN cl_val_co_tp
    ON cl_val_co_tp.cl_code = 'CTCK'
