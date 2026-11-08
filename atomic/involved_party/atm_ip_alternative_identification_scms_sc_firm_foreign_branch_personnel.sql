/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_FOREIGN_BRANCH_PERSONNEL
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-25		tuan.nguyenvanb		[LLD SCMS lld_SCMS_SC_FIRM_FOREIGN_BRANCH_PERSONNEL_IP_Alt_Identification.yaml] Tao moi model con theo LLD
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , national_id
        , id_issued_date
        , issue_place
    FROM {{ ref('ods_scms_sc_firm_foreign_branch_personnel') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH_PERSONNEL', "fp.id") }} AS ip_id
    , CAST(fp.id AS string)                                                                 AS ip_code
    , CAST('SCMS_SC_FIRM_FOREIGN_BRANCH_PERSONNEL' AS string)                               AS src_stm_code
    , CAST('NATIONAL_ID' AS string)                                                         AS identification_tp_code
    , CAST(fp.national_id AS string)                                                        AS identification_nbr
    , CAST(fp.id_issued_date AS date)                                                       AS identification_issue_dt
    , CAST(fp.issue_place AS string)                                                        AS identification_issue_place
FROM src AS fp
WHERE fp.national_id IS NOT NULL
