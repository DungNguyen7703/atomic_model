/*
*--------------------------------------------------------------------*
* Program code: atm_foreign_investor_report
* Program name: Atomic Foreign Investor Report
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH fo_in_re AS (
    SELECT
        sheet_id
        , rpt_id
        , report_code
        , report_name
        , legal_basis
        , template_status
        , sheet_code
        , sheet_name
        , sheet_index
    FROM {{ source('source_fims_bcd', 'raw_foreign_investor_report') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_FOREIGN_INVESTOR_REPORT', "fo_in_re.sheet_id") }} AS fir_id
    , CAST(fo_in_re.sheet_id AS string)                                                      AS fir_code
    , CAST('FIMS_FOREIGN_INVESTOR_REPORT' AS string)                                         AS src_stm_code
    , CAST(fo_in_re.rpt_id AS string)                                                        AS rpt_id
    , CAST(fo_in_re.report_code AS string)                                                   AS rpt_code
    , CAST(fo_in_re.report_name AS string)                                                   AS rpt_nm
    , CAST(fo_in_re.legal_basis AS string)                                                   AS legal_basis
    , CAST(fo_in_re.template_status AS int)                                                  AS rpt_status
    , CAST(fo_in_re.sheet_code AS string)                                                    AS sheet_code
    , CAST(fo_in_re.sheet_name AS string)                                                    AS sheet_nm
    , CAST(fo_in_re.sheet_index AS int)                                                      AS sheet_index
FROM fo_in_re