/*
*--------------------------------------------------------------------*
* Program code: atm_sc_disclosure_securities_offering
* Program name: Atomic Securities Company Disclosure Securities Offering
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH di_se_of AS (
    SELECT
        id
        , sc_firm_info_id
        , event_type_id
        , offering_type
        , securities_type
        , data_source
        , assessment
        , item_category
        , matter
        , document_number
        , document_date
        , document_file_path
        , offering_method
        , target_investors
        , offering_purpose
        , underwriter
        , underwriting_company
        , advisor
        , disclosure_person_name
        , quantity
        , offered_quantity
        , total_offered_quantity
        , total_offered_completed
        , item_value
        , offering_price
        , total_value
        , expected_total_amount
        , proceeds_collected
        , valid_date
        , offering_date
        , start_date
        , end_date
        , offering_start_date
        , offering_end_date
        , expected_start_date
        , expected_end_date
        , result_report_date
        , first_dossier_submission_date
        , complete_dossier_submission_date
        , extension_to_date
        , disclosure_date
        , sent_at
        , collateral_required
        , synced_from_admin_proc
        , bond_type
        , bond_code
        , bond_face_value
        , maturity_years
        , interest_payment_period
        , bond_holder_representative
        , issuance_date
        , covered_warrant_type
        , covered_warrant_name
        , listed_cw_code
        , underlying_securities_code
        , underlying_securities_issuer
        , cw_term_months
        , cw_registered_quantity
        , cw_permitted_quantity
        , cw_distributed_quantity
        , cw_shares_per_warrant
        , conversion_ratio
        , converted_shares_quantity
        , registered_offering_price
        , cw_actual_offering_price
        , cw_offering_date
        , cw_maturity_date
        , collateral_settlement_value
        , collateral_deposit_bank
        , cw_deposit_amount
        , cw_proceeds
        , attachment_path
        , result_attachment_path
        , error_description
        , created_at
    FROM {{ ref('ods_scms_disclosure_securities_offering') }}
),

sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_DISCLOSURE_SECURITIES_OFFERING', "di_se_of.id") }} AS sc_disclosure_securities_offering_id
    , CAST(di_se_of.id AS string)                                                             AS sc_disclosure_securities_offering_code
    , CAST('SCMS_DISCLOSURE_SECURITIES_OFFERING' AS string)                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}               AS sc_id
    , CAST(sc_fi_in.code AS string)                                                           AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_CAT_EVENT_TYPE', "di_se_of.event_type_id") }}    AS cl_sc_event_tp_id
    , CAST(di_se_of.event_type_id AS string)                                                  AS cl_sc_event_tp_code
    , CAST(di_se_of.offering_type AS int)                                                     AS offering_tp_code
    , CAST(di_se_of.securities_type AS string)                                                AS securities_tp_code
    , CAST(di_se_of.data_source AS string)                                                    AS data_src_code
    , CAST(di_se_of.assessment AS string)                                                     AS assessment_code
    , CAST(di_se_of.item_category AS string)                                                  AS item_category_code
    , CAST(di_se_of.matter AS int)                                                            AS matter
    , CAST(di_se_of.document_number AS string)                                                AS document_nbr
    , CAST(di_se_of.document_date AS date)                                                    AS document_dt
    , CAST(di_se_of.document_file_path AS string)                                             AS document_file_path
    , CAST(di_se_of.offering_method AS string)                                                AS offering_method
    , CAST(di_se_of.target_investors AS string)                                               AS target_investors
    , CAST(di_se_of.offering_purpose AS string)                                               AS offering_purpose
    , CAST(di_se_of.underwriter AS string)                                                    AS underwriter
    , CAST(di_se_of.underwriting_company AS string)                                           AS underwriting_company
    , CAST(di_se_of.advisor AS string)                                                        AS advisor
    , CAST(di_se_of.disclosure_person_name AS string)                                         AS disclosure_person_nm
    , CAST(di_se_of.quantity AS bigint)                                                       AS quantity
    , CAST(di_se_of.offered_quantity AS bigint)                                               AS offered_quantity
    , CAST(di_se_of.total_offered_quantity AS bigint)                                         AS total_offered_quantity
    , CAST(di_se_of.total_offered_completed AS bigint)                                        AS total_offered_completed
    , CAST(di_se_of.item_value AS decimal(23,2))                                              AS item_val_amt
    , CAST(di_se_of.offering_price AS decimal(23,2))                                          AS offering_price_amt
    , CAST(di_se_of.total_value AS decimal(23,2))                                             AS total_val_amt
    , CAST(di_se_of.expected_total_amount AS decimal(23,2))                                   AS expected_total_amt
    , CAST(di_se_of.proceeds_collected AS decimal(23,2))                                      AS proceeds_collected_amt
    , CAST(di_se_of.valid_date AS timestamp)                                                  AS valid_tms
    , CAST(di_se_of.offering_date AS timestamp)                                               AS offering_tms
    , CAST(di_se_of.start_date AS date)                                                       AS start_dt
    , CAST(di_se_of.end_date AS date)                                                         AS end_dt
    , CAST(di_se_of.offering_start_date AS date)                                              AS offering_start_dt
    , CAST(di_se_of.offering_end_date AS date)                                                AS offering_end_dt
    , CAST(di_se_of.expected_start_date AS date)                                              AS expected_start_dt
    , CAST(di_se_of.expected_end_date AS date)                                                AS expected_end_dt
    , CAST(di_se_of.result_report_date AS date)                                               AS result_rpt_dt
    , CAST(di_se_of.first_dossier_submission_date AS date)                                    AS first_dossier_submission_dt
    , CAST(di_se_of.complete_dossier_submission_date AS date)                                 AS complete_dossier_submission_dt
    , CAST(di_se_of.extension_to_date AS date)                                                AS extension_to_dt
    , CAST(di_se_of.disclosure_date AS timestamp)                                             AS disclosure_tms
    , CAST(di_se_of.sent_at AS timestamp)                                                     AS sent_tms
    , CAST(di_se_of.collateral_required AS int)                                               AS collateral_required_ind
    , CAST(di_se_of.synced_from_admin_proc AS int)                                            AS synced_from_admin_procedure_ind
    , CAST(di_se_of.bond_type AS string)                                                      AS bond_tp_code
    , CAST(di_se_of.bond_code AS string)                                                      AS bond_code
    , CAST(di_se_of.bond_face_value AS decimal(23,2))                                         AS bond_face_val_amt
    , CAST(di_se_of.maturity_years AS int)                                                    AS maturity_years
    , CAST(di_se_of.interest_payment_period AS string)                                        AS interest_payment_period
    , CAST(di_se_of.bond_holder_representative AS string)                                     AS bond_holder_representative
    , CAST(di_se_of.issuance_date AS date)                                                    AS issuance_dt
    , CAST(di_se_of.covered_warrant_type AS string)                                           AS covered_warrant_tp_code
    , CAST(di_se_of.covered_warrant_name AS string)                                           AS covered_warrant_nm
    , CAST(di_se_of.listed_cw_code AS string)                                                 AS listed_cw_code
    , CAST(di_se_of.underlying_securities_code AS string)                                     AS underlying_securities_code
    , CAST(di_se_of.underlying_securities_issuer AS string)                                   AS underlying_securities_issuer
    , CAST(di_se_of.cw_term_months AS int)                                                    AS cw_term_months
    , CAST(di_se_of.cw_registered_quantity AS int)                                            AS cw_registered_quantity
    , CAST(di_se_of.cw_permitted_quantity AS int)                                             AS cw_permitted_quantity
    , CAST(di_se_of.cw_distributed_quantity AS int)                                           AS cw_distributed_quantity
    , CAST(di_se_of.cw_shares_per_warrant AS int)                                             AS cw_shares_per_warrant
    , CAST(di_se_of.conversion_ratio AS int)                                                  AS conversion_ratio
    , CAST(di_se_of.converted_shares_quantity AS int)                                         AS converted_shares_quantity
    , CAST(di_se_of.registered_offering_price AS decimal(23,2))                               AS registered_offering_price_amt
    , CAST(di_se_of.cw_actual_offering_price AS decimal(23,2))                                AS cw_actual_offering_price_amt
    , CAST(di_se_of.cw_offering_date AS date)                                                 AS cw_offering_dt
    , CAST(di_se_of.cw_maturity_date AS date)                                                 AS cw_maturity_dt
    , CAST(di_se_of.collateral_settlement_value AS decimal(23,2))                             AS collateral_settlement_val_amt
    , CAST(di_se_of.collateral_deposit_bank AS string)                                        AS collateral_deposit_bank
    , CAST(di_se_of.cw_deposit_amount AS decimal(23,2))                                       AS cw_deposit_amt
    , CAST(di_se_of.cw_proceeds AS decimal(23,2))                                             AS cw_proceeds_amt
    , CAST(di_se_of.attachment_path AS string)                                                AS attachment_path
    , CAST(di_se_of.result_attachment_path AS string)                                         AS result_attachment_path
    , CAST(di_se_of.error_description AS string)                                              AS error_description
    , CAST(di_se_of.created_at AS timestamp)                                                  AS src_record_insert_tms
FROM di_se_of
    LEFT JOIN sc_fi_in ON di_se_of.sc_firm_info_id = sc_fi_in.id