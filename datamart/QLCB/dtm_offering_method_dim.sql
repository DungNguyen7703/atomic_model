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
        and deleted_indicator = 0
)

SELECT
    CAST({{ generate_surrogate_key_bigint('IDS_SECURITIES_OFFERING_PLAN', 'src.offering_method_code') }} AS string) AS offering_method_dim_id,
    CAST(src.offering_method_code AS string)                                                                        AS offering_method_code,
    CAST(clv.cl_nm AS string)                                                                                       AS offering_method_nm,
    CAST(
        CASE src.offering_method_code
            WHEN '1'  THEN 'Công chúng'
            WHEN '2'  THEN 'Công chúng'
            WHEN '3'  THEN 'Công chúng'
            WHEN '4'  THEN 'Công chúng'
            WHEN '5'  THEN 'Riêng lẻ'
            WHEN '9'  THEN 'ESOP'
            WHEN '10' THEN 'ESOP'
            WHEN '7'  THEN 'Trả cổ tức'
            WHEN '8'  THEN 'Tăng vốn từ VCSH'
            ELSE 'Khác'
        END AS string)                                                                                               AS offering_method_group_nm,
    CAST(src.src_stm_code AS string)                                                                                AS src_stm_code
FROM src
LEFT JOIN atomic.uat_atm.cl_value clv
    ON clv.cl_code = src.offering_method_code
    AND clv.schema_code = 'SO_OFFERING_METHOD'
