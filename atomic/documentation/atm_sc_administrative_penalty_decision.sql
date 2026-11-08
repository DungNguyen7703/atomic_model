/*
*--------------------------------------------------------------------*
* Program code: atm_sc_administrative_penalty_decision
* Program name: Atomic Securities Company Administrative Penalty Decision
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_ad_pe_de AS (
    SELECT
        id
        , sc_firm_info_id
        , decision_number
        , issued_date
        , penalty_form
        , signatory
        , registered_address
        , tax_code_business_license
        , implementation_status
        , data_source
        , fine_amount
        , total_fine_amount
        , paid_amount
        , fine_payment_deadline
        , decision_file_path
        , sync_date
        , note
    FROM {{ ref('ods_scms_sc_firm_admin_penalty_decision') }}
),

sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_ADMIN_PENALTY_DECISION', "sc_fi_ad_pe_de.id") }} AS sc_administrative_pd_id
    , CAST(sc_fi_ad_pe_de.id AS string)                                                             AS sc_administrative_pd_code
    , CAST('SCMS_SC_FIRM_ADMIN_PENALTY_DECISION' AS string)                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                     AS sc_id
    , CAST(sc_fi_ad_pe_de.sc_firm_info_id AS string)                                                AS sc_code
    , CAST(sc_fi_ad_pe_de.decision_number AS string)                                                AS decision_nbr
    , CAST(sc_fi_ad_pe_de.issued_date AS date)                                                      AS issued_dt
    , CAST(sc_fi_ad_pe_de.penalty_form AS string)                                                   AS penalty_form
    , CAST(sc_fi_ad_pe_de.signatory AS string)                                                      AS signatory
    , CAST(sc_fi_ad_pe_de.registered_address AS string)                                             AS registered_adr
    , CAST(sc_fi_ad_pe_de.tax_code_business_license AS string)                                      AS tax_code_business_license
    , CAST(sc_fi_ad_pe_de.implementation_status AS string)                                          AS implementation_status_code
    , CAST(sc_fi_ad_pe_de.data_source AS string)                                                    AS data_src
    , CAST(sc_fi_ad_pe_de.fine_amount AS decimal(23,2))                                             AS fine_amt
    , CAST(sc_fi_ad_pe_de.total_fine_amount AS decimal(23,2))                                       AS total_fine_amt
    , CAST(sc_fi_ad_pe_de.paid_amount AS decimal(23,2))                                             AS paid_amt
    , CAST(sc_fi_ad_pe_de.fine_payment_deadline AS string)                                          AS fine_payment_deadline
    , CAST(sc_fi_ad_pe_de.decision_file_path AS string)                                             AS decision_file_path
    , CAST(sc_fi_ad_pe_de.sync_date AS date)                                                        AS sync_dt
    , CAST(sc_fi_ad_pe_de.note AS string)                                                           AS note
FROM sc_fi_ad_pe_de
    LEFT JOIN sc_fi_in ON sc_fi_ad_pe_de.SC_FIRM_INFO_ID = sc_fi_in.ID