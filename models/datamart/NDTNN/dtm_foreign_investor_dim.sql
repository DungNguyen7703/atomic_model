/*
*--------------------------------------------------------------------*
* Program code: dtm_foreign_investor_dim
* Program name: Dtm Foreign Investor Dim
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH fo_in AS (
    SELECT 
        foreign_investor_code, 
        full_nm, 
        investor_object_tp_code, 
        investor_tp_code, 
        src_stm_code
    FROM {{ ref('atm_foreign_investor') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FIMS_INVESTOR'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('FIMS_INVESTOR', 'foreign_investor_code') }} AS string) AS investor_dim_id,
    CAST(foreign_investor_code AS string)                              AS investor_id,
    CAST(full_nm AS string)                                            AS investor_nm,
    CAST(investor_object_tp_code AS string)                            AS investor_object_tp_code,
    CAST(investor_tp_code AS string)                                   AS investor_tp_code,
    CAST(src_stm_code AS string)                                       AS src_stm_code
FROM fo_in
