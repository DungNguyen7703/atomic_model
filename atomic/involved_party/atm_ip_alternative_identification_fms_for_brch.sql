/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FMS.FOR_BRCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-07		claude				Thêm dấu phẩy thiếu sau license_date (reg_no đang thành alias của license_date);
*										sắp lại thứ tự cột theo atm_ip_alternative_identification; LICENSE_DATE chỉ gán cho
*										ESTABLISHMENT_OPERATION_LICENSE theo LLD FOR_BRCH_IP_Alt_Identification
* 2026-10-25		tuan.nguyenvanb		[LLD ip_alternative_identification] sap lai thu tu cot theo LLD (ip_id, ip_code, src_stm_code, tp, nbr, issue_dt, issue_place)
*--------------------------------------------------------------------*
*/

WITH fo_br AS (
    SELECT
        id,
        license_date,
        reg_no,
        license,
        tax_code
    FROM {{ ref('ods_fms_for_brch') }}
),

unpvt AS (
    SELECT *
    FROM fo_br
    UNPIVOT (
        identification_nbr
        FOR identification_tp_code IN (
            reg_no AS BUSINESS_LICENSE,
            license AS ESTABLISHMENT_OPERATION_LICENSE,
            tax_code AS TAX_ID
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_FOR_BRCH', "id") }} AS ip_id
    , CAST(id AS string)                                        AS ip_code
    , CAST('FMS_FOR_BRCH' AS string)                            AS src_stm_code
    , CAST(identification_tp_code AS string)                    AS identification_tp_code
    , CAST(identification_nbr AS string)                        AS identification_nbr
    , CAST(CASE WHEN identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
              THEN license_date END AS date) AS identification_issue_dt
    , CAST(NULL AS string)                                      AS identification_issue_place
FROM unpvt
