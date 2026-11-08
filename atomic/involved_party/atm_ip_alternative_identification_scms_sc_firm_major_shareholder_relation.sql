/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_MAJOR_SHAREHOLDER_RELATION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-25		tuan.nguyenvanb		[LLD SCMS lld_SCMS_SC_FIRM_MAJOR_SHAREHOLDER_RELATION_IP_Alt_Identification.yaml] Tao moi model con theo LLD
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , identification_number
        , issue_date
        , issue_place
    FROM {{ ref('ods_scms_sc_firm_major_shareholder_relation') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_MAJOR_SHAREHOLDER_RELATION', "ms.id") }} AS ip_id
    , CAST(ms.id AS string)                                                                   AS ip_code
    , CAST('SCMS_SC_FIRM_MAJOR_SHAREHOLDER_RELATION' AS string)                               AS src_stm_code
    , CAST('NATIONAL_ID' AS string)                                                           AS identification_tp_code
    , CAST(ms.identification_number AS string)                                                AS identification_nbr
    , CAST(ms.issue_date AS date)                                                             AS identification_issue_dt
    , CAST(ms.issue_place AS string)                                                          AS identification_issue_place
FROM src AS ms
WHERE ms.identification_number IS NOT NULL
