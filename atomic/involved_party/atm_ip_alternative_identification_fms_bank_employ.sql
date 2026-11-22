/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification_fms_bank_employ
* Program name: Atomic IP Alternative Identification FMS.BANK_EMPLOY
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao nhanh FMS theo lld_FMS_BANK_EMPLOY_IP_Alt_Identification.yaml (UAT chua co).
*--------------------------------------------------------------------*
*/

WITH be AS (
    SELECT
        id
        , id_no
        , id_date
    FROM {{ ref('ods_fms_bank_employ') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_BANK_EMPLOY', "be.id") }} AS ip_id
    , CAST(be.id AS string)                                           AS ip_code
    , CAST('FMS_BANK_EMPLOY' AS string)                               AS src_stm_code
    , CAST('IDENTIFICATION' AS string)                                AS identification_tp_code
    , CAST(be.id_no AS string)                                        AS identification_nbr
    , CAST(be.id_date AS date)                                        AS identification_issue_dt
    , CAST(NULL AS string)                                            AS identification_issue_place
FROM be
WHERE be.id_no IS NOT NULL
