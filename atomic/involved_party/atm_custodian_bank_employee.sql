/*
*--------------------------------------------------------------------*
* Program code: atm_custodian_bank_employee
* Program name: Atomic Custodian Bank Employee
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_FMS_BANK_EMPLOY.yaml (Fundamental). UAT chua co model nay.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , bank_id
        , item_name
        , cert_no
        , cert_law
        , cert_audit
        , cert_date
        , position
    FROM {{ ref('ods_fms_bank_employ') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_BANK_EMPLOY', "src.id") }}    AS custodian_bank_employee_id
    , CAST(src.id AS string)                                              AS custodian_bank_employee_code
    , CAST('FMS_BANK_EMPLOY' AS string)                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_BANK_MONI', "src.bank_id") }} AS custodian_bank_id
    , CAST(src.bank_id AS string)                                         AS custodian_bank_code
    , CAST(src.item_name AS string)                                       AS custodian_bank_employee_full_nm
    , CAST(src.cert_no AS string)                                         AS practice_certificate_nbr
    , CAST(src.cert_law AS string)                                        AS legal_certificate_nbr
    , CAST(src.cert_audit AS string)                                      AS audit_certificate_nbr
    , CAST(src.cert_date AS date)                                         AS practice_certificate_dt
    , CAST(src.position AS string)                                        AS current_position_title
FROM src
