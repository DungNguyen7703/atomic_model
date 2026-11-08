/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FMS.STF_FG_BRCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-07		claude				NATIONAL_ID -> IDENTIFICATION; bổ sung ESTABLISHMENT_OPERATION_LICENSE (LICENSE, LICENSE_DATE);
*										ISSUED_CODE chỉ gán cho IDENTIFICATION theo LLD STF_FG_BRCH_IP_Alt_Identification
* 2026-10-25		tuan.nguyenvanb		[LLD ip_alternative_identification] sap lai thu tu cot theo LLD (ip_id, ip_code, src_stm_code, tp, nbr, issue_dt, issue_place)
*--------------------------------------------------------------------*
*/

WITH st_fg_br AS (
    SELECT
        id
        , issued_code
        , id_code
        , date_code
        , practice_cert_no
        , practice_cert_issue_date
        , license
        , license_date
    FROM {{ ref('ods_fms_stf_fg_brch') }}
),

unpvt AS (
    SELECT *
    FROM st_fg_br
    UNPIVOT (
        (identification_nbr, identification_issue_dt)
        FOR identification_tp_code IN (
            (id_code, date_code) AS IDENTIFICATION,
            (practice_cert_no, practice_cert_issue_date) AS PRACTITIONER_LICENSE,
            (license, license_date) AS ESTABLISHMENT_OPERATION_LICENSE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_STF_FG_BRCH', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                           AS ip_code
    , CAST('FMS_STF_FG_BRCH' AS string)                                  AS src_stm_code
    , CAST(unpvt.identification_tp_code AS string)                       AS identification_tp_code
    , CAST(unpvt.identification_nbr AS string)                           AS identification_nbr
    , CAST(unpvt.identification_issue_dt AS date)                        AS identification_issue_dt
    , CAST(CASE WHEN unpvt.identification_tp_code = 'IDENTIFICATION'
                THEN unpvt.issued_code END AS string) AS identification_issue_place
FROM unpvt