/*
*--------------------------------------------------------------------*
* Program code: dtm_sp_license_certificate_type_dim
* Program name: Dtm Sp License Certificate Type Dim
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH sp_li_ce_ty AS (
    SELECT
        sp_license_certificate_tp_code,
        certificate_tp_nm,
        src_stm_code
    FROM {{ ref('atm_sp_license_certificate_type') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_CERTIFICATES'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('NHNCK_CERTIFICATES', 'sp_license_certificate_tp_code') }} AS string) AS certificate_tp_dim_id,
    CAST(sp_license_certificate_tp_code AS string)               AS certificate_tp_code,
    CAST(certificate_tp_nm AS string)                            AS certificate_tp_nm,
    CAST(src_stm_code AS string)                                 AS src_stm_code
FROM sp_li_ce_ty
