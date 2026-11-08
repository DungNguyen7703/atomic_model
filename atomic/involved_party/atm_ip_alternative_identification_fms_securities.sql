/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FMS.SECURITIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-07		claude				ID_NO: TAX_ID -> ESTABLISHMENT_OPERATION_LICENSE theo LLD SECURITIES_IP_Alt_Identification;
*										ID_DATE/ID_ADD chỉ gán cho ESTABLISHMENT_OPERATION_LICENSE (BUSINESS_LICENSE không có)
* 2026-10-25		tuan.nguyenvanb		[LLD ip_alternative_identification] sap lai thu tu cot theo LLD (ip_id, ip_code, src_stm_code, tp, nbr, issue_dt, issue_place)
*--------------------------------------------------------------------*
*/

WITH secu AS (
    SELECT
        id
        , id_date
        , id_add
        , reg_no
        , id_no
    FROM {{ ref('ods_fms_securities') }}
),

unpvt AS (
    SELECT *
    FROM secu
    UNPIVOT (
        identification_nbr
        FOR identification_tp_code IN (
            reg_no AS BUSINESS_LICENSE,
            id_no AS ESTABLISHMENT_OPERATION_LICENSE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_SECURITIES', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                          AS ip_code
    , CAST('FMS_SECURITIES' AS string)                                  AS src_stm_code
    , CAST(unpvt.identification_tp_code AS string)                      AS identification_tp_code
    , CAST(unpvt.identification_nbr AS string)                          AS identification_nbr
    , CAST(CASE WHEN unpvt.identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
                THEN unpvt.id_date END AS date) AS identification_issue_dt
    , CAST(CASE WHEN unpvt.identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
                THEN unpvt.id_add END AS string) AS identification_issue_place
FROM unpvt