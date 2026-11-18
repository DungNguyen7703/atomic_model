/*
*--------------------------------------------------------------------*
* Program code: atm_sc_shareholder_representative
* Program name: Atomic Securities Company Shareholder Representative
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
        , sc_firm_info_id
        , sc_firm_shareholder_id
        , record_status
        , representative_name
        , position
        , id_number
        , issue_date
        , issue_place
        , shares_count
        , ownership_ratio
        , attachment_path
        , note
    FROM {{ ref('ods_scms_sc_firm_shareholder_representative') }}
),

sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SHAREHOLDER_REPRESENTATIVE', "sc_fi_sh_re.id") }}        AS sc_shareholder_representative_id
    , CAST(sc_fi_sh_re.id AS string)                                                                        AS sc_shareholder_representative_code
    , CAST('SCMS_SC_FIRM_SHAREHOLDER_REPRESENTATIVE' AS string)                                             AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                             AS sc_id
    , CAST(sc_fi_sh_re.sc_firm_info_id AS string)                                                           AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SHAREHOLDER', "sc_fi_sh_re.sc_firm_shareholder_id") }} AS sc_shareholder_id
    , CAST(sc_fi_sh_re.sc_firm_shareholder_id AS string)                                                    AS sc_shareholder_code
    , CAST(sc_fi_sh_re.record_status AS string)                                                             AS record_status_code
    , CAST(sc_fi_sh_re.representative_name AS string)                                                       AS representative_nm
    , CAST(sc_fi_sh_re.position AS string)                                                                  AS position
    , CAST(sc_fi_sh_re.id_number AS string)                                                                 AS identification_nbr
    , CAST(sc_fi_sh_re.issue_date AS date)                                                                  AS issue_dt
    , CAST(sc_fi_sh_re.issue_place AS string)                                                               AS issue_place
    , CAST(sc_fi_sh_re.shares_count AS int)                                                                 AS shares_count
    , CAST(sc_fi_sh_re.ownership_ratio AS decimal(5,2))                                                     AS ownership_ratio
    , CAST(sc_fi_sh_re.attachment_path AS string)                                                           AS attachment_path
    , CAST(sc_fi_sh_re.note AS string)                                                                      AS note
FROM sc_fi_sh_re
    LEFT JOIN sc_fi_in ON sc_fi_sh_re.SC_FIRM_INFO_ID = sc_fi_in.ID