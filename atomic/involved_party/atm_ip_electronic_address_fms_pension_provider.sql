/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address_fms_pension_provider
* Program name: Atomic IP Electronic Address FMS.PENSION_PROVIDER
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao nhanh FMS theo lld_FMS_PENSION_PROVIDER_IP_Electronic_Address.yaml (UAT chua co).
*--------------------------------------------------------------------*
*/

WITH pp AS (
    SELECT
        id
        , phone
        , fax
    FROM {{ ref('ods_fms_pension_provider') }}
    WHERE id IS NOT NULL
),

unpvt AS (
    SELECT *
    FROM pp
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            phone AS PHONE,
            fax AS FAX
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_PENSION_PROVIDER', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                                AS ip_code
    , CAST('FMS_PENSION_PROVIDER' AS string)                                  AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                            AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                                AS electronic_adr_val
FROM unpvt
