/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_SHAREHOLDER_REPRESENTATIVE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_sh_re AS (
    SELECT
        id
        , id_number
        , issue_date
        , issue_place
    FROM {{ ref('ods_scms_sc_firm_shareholder_representative') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SHAREHOLDER_REPRESENTATIVE', "sc_fi_sh_re.id") }} AS ip_id
    , CAST(sc_fi_sh_re.id AS string)                                                                   AS ip_code
    , CAST('SCMS_SC_FIRM_SHAREHOLDER_REPRESENTATIVE' AS string)                                          AS src_stm_code
    , CAST('LEGACY_NATIONAL_ID' AS string)                                                             AS identification_tp_code
    , CAST(sc_fi_sh_re.id_number AS string)                                                            AS identification_nbr
    , CAST(sc_fi_sh_re.issue_date AS date)                                                             AS identification_issue_dt
    , CAST(sc_fi_sh_re.issue_place AS string)                                                          AS identification_issue_place
FROM sc_fi_sh_re