/*
*--------------------------------------------------------------------*
* Program code: atm_cl_ecat_administrative_procedure
* Program name: Atomic Classification ECAT Administrative Procedure
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Theo lld_ECAT_ADMINISTRATIVE_PROCEDURE.yaml (2026-10-29), cung pattern atm_cl_ecat_department (Relative -> scd2). Khu trung theo code (VERSION lon nhat), chi lay dong hien hanh (DELETED = 0, EFFECTIVE = 1).
* 2026-11-12		tuan.nguyenvanb		Doi kieu 5 cot cho giong ODS (procedure_level string, processing_time_amount bigint, fee_amount bigint, effective/expiration_status_date timestamp) theo yeu cau; lech design LLD (int/int/decimal(23,2)/date/date).
*--------------------------------------------------------------------*
*/

WITH ap_all AS (
    SELECT
        code
        , name
        , description
        , field_group
        , procedure_group
        , procedure_level
        , implementation_method
        , implementation_result
        , applied_subject
        , processing_time_amount
        , processing_time_unit
        , fee_amount
        , fee_unit_currency_id
        , fee_payment_method
        , coordinating_agency
        , effective_status_date
        , expiration_status_date
    FROM {{ ref('ods_ecat_administrative_procedure') }}
)

SELECT
    {{ generate_surrogate_key_bigint('ECAT_ADMINISTRATIVE_PROCEDURE', "ap_all.code") }} AS cl_ecat_ap_id
    , CAST(ap_all.code AS string)                                                       AS cl_ecat_ap_code
    , CAST('ECAT_ADMINISTRATIVE_PROCEDURE' AS string)                                   AS src_stm_code
    , CAST(ap_all.name AS string)                                                       AS cl_ecat_ap_nm
    , CAST(ap_all.description AS string)                                                AS description
    , CAST(ap_all.field_group AS string)                                                AS field_group_nm
    , CAST(ap_all.procedure_group AS string)                                            AS procedure_group_nm
    , CAST(ap_all.procedure_level AS string)                                            AS procedure_level_code
    , CAST(ap_all.implementation_method AS string)                                      AS implementation_method
    , CAST(ap_all.implementation_result AS string)                                      AS implementation_result
    , CAST(ap_all.applied_subject AS string)                                            AS applied_subject
    , CAST(ap_all.processing_time_amount AS bigint)                                     AS processing_time_amt
    , CAST(ap_all.processing_time_unit AS string)                                       AS processing_time_unit
    , CAST(ap_all.fee_amount AS decimal(23,2))                                          AS fee_amt
    , CAST(ap_all.fee_unit_currency_id AS string)                                       AS fee_currency_code
    , CAST(ap_all.fee_payment_method AS string)                                         AS fee_payment_method
    , CAST(ap_all.coordinating_agency AS string)                                        AS coordinating_agency
    , CAST(ap_all.effective_status_date AS timestamp)                                   AS effective_dt
    , CAST(ap_all.expiration_status_date AS timestamp)                                  AS expiration_dt
FROM ap_all
