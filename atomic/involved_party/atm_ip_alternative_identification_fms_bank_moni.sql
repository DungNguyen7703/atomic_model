/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FMS.BANK_MONI
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-27		claude				Sap lai thu tu cot SELECT ve dung chuan Shape A
*                                       (ip_id, ip_code, src_stm_code, identification_tp_code,
*                                       identification_nbr, identification_issue_dt,
*                                       identification_issue_place) khop voi da so cac child khac.
*                                       Fix ngay 2026-10-07 doi sang Shape B (src_stm_code dau tien)
*                                       la huong sai: no khien cot thu 4 cua UNION ALL (theo vi tri)
*                                       lech giua cac child, Spark suy ra kieu STRING cho vi tri
*                                       identification_issue_dt, ghi vao _hstr (DATE) bao loi
*                                       CANNOT_SAFELY_CAST.
*--------------------------------------------------------------------*
*/

WITH ba_mo AS (
    SELECT
        id
        , cert_no
    FROM {{ ref('ods_fms_bank_moni') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_BANK_MONI', "ba_mo.id") }} AS ip_id
    , CAST(ba_mo.id AS string)                                       AS ip_code
    , CAST('FMS_BANK_MONI' AS string)                                  AS src_stm_code
    , CAST('ELIGIBILITY_CERTIFICATE' AS string)                      AS identification_tp_code
    , CAST(ba_mo.cert_no AS string)                                  AS identification_nbr
    , CAST(NULL AS date)                                             AS identification_issue_dt
    , CAST(NULL AS string)                                           AS identification_issue_place
FROM ba_mo