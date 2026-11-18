/*
*--------------------------------------------------------------------*
* Program code: dtm_foreign_investor_reporting_entity_dim
* Program name: Foreign Investor Reporting Entity Dimension
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - atm_cl_foreign_investor_reporting_entity duoc materialize theo
*   strategy SCD2 (khong co bang phu _hstr va khong co cot ds_snpst_dt).
*   Ban ghi hien hanh: ds_rcrd_st = 'ACTIVE' AND
*   ds_rcrd_end_dt = to_date('2400-01-01').
* - BK ghep (reporting_entity_code, reporting_entity_tp_code) - ma doi
*   tuong khong duy nhat giua cac loai - nen surrogate key hash tren
*   CONCAT(reporting_entity_code, '|', reporting_entity_tp_code).
*--------------------------------------------------------------------*
*/

WITH cl_fo_in_re_en AS (
    SELECT
        reporting_entity_code,
        reporting_entity_tp_code,
        reporting_entity_tp_nm,
        entity_reference_nbr,
        reporting_entity_nm,
        reporting_entity_short_nm,
        src_stm_code
    FROM {{ ref('atm_cl_foreign_investor_reporting_entity') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND ds_rcrd_end_dt = to_date('2400-01-01')
        AND src_stm_code = 'FIMS_CL_FOREIGN_INVESTOR_REPORTING_ENTITY'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('FIMS_CL_FOREIGN_INVESTOR_REPORTING_ENTITY', "CONCAT(cl_fo_in_re_en.reporting_entity_code, '|', cl_fo_in_re_en.reporting_entity_tp_code)") }} AS string) AS foreign_investor_reporting_entity_dim_id,
    CAST(cl_fo_in_re_en.reporting_entity_code AS string)                                                                                                                               AS reporting_entity_code,
    CAST(cl_fo_in_re_en.reporting_entity_tp_code AS string)                                                                                                                            AS reporting_entity_tp_code,
    CAST(cl_fo_in_re_en.reporting_entity_tp_nm AS string)                                                                                                                              AS reporting_entity_tp_nm,
    CAST(cl_fo_in_re_en.entity_reference_nbr AS string)                                                                                                                                AS entity_reference_nbr,
    CAST(cl_fo_in_re_en.reporting_entity_nm AS string)                                                                                                                                 AS reporting_entity_nm,
    CAST(cl_fo_in_re_en.reporting_entity_short_nm AS string)                                                                                                                           AS reporting_entity_short_nm,
    CAST(cl_fo_in_re_en.src_stm_code AS string)                                                                                                                                        AS src_stm_code
FROM cl_fo_in_re_en
