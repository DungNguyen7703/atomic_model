/*
*--------------------------------------------------------------------*
* Program code: dtm_offering_method_dim
* Program name: Offering Method Dimension
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT DISTINCT
        offering_method_code,
        src_stm_code
    FROM {{ ref('atm_pc_securities_offering_plan') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING_PLAN'
        and deleted_ind = 0
)

SELECT
    CAST({{ generate_surrogate_key_bigint('IDS_SECURITIES_OFFERING_PLAN', 'src.offering_method_code') }} AS string) AS offering_method_dim_id,
    CAST(src.offering_method_code AS string)                                                                        AS offering_method_code,
    CAST(clv.cl_nm AS string)                                                                                       AS offering_method_nm,
    CAST(
        CASE
            WHEN src.offering_method_code = '1'  THEN 'Đang IPO hoặc công chúng'
            WHEN src.offering_method_code = '2'  THEN 'Đang IPO hoặc công chúng'
            WHEN src.offering_method_code = '3'  THEN 'Đang IPO hoặc công chúng'
            --WHEN src.offering_method_code = '4'  THEN 'Công chúng'
            when src.offering_method_code = '13' THEN 'Đang IPO hoặc công chúng'
            WHEN src.offering_method_code = '5'  THEN 'Riêng lẻ'
            WHEN src.offering_method_code = '9'  THEN 'ESOP'
            WHEN src.offering_method_code = '10' THEN 'ESOP'
            WHEN src.offering_method_code = '7'  THEN 'Trả cổ tức'
            WHEN src.offering_method_code = '8'  THEN 'Tăng vốn từ VCSH'
            when src.offering_method_code = '11' then 'chào bán TP ra quốc tế'
            when src.offering_method_code is null then 'Khác'
            else clv.cl_nm
        END AS string)                                                                                               AS offering_method_group_nm,
    CAST(src.src_stm_code AS string)                                                                                AS src_stm_code
FROM src
LEFT JOIN atomic.uat_atm.cl_value clv
    ON clv.cl_code = src.offering_method_code
    AND clv.schema_code = 'SO_OFFERING_METHOD'
