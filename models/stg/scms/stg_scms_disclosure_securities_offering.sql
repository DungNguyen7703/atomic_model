/*
*--------------------------------------------------------------------*
* Program code: stg_scms_disclosure_securities_offering
* Program name: Staging SCMS.DISCLOSURE_SECURITIES_OFFERING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                                   AS id
    , CAST(sc_firm_info_id AS bigint)                    AS sc_firm_info_id
    , CAST(document_number AS string)                    AS document_number
    , CAST(document_date AS date)                        AS document_date
    , CAST(valid_date AS timestamp)                      AS valid_date
    , CAST(offering_date AS timestamp)                   AS offering_date
    , CAST(end_date AS date)                             AS end_date
    , CAST(offering_method AS string)                    AS offering_method
    , CAST(target_investors AS string)                   AS target_investors
    , CAST(quantity AS decimal(38,0))                    AS quantity
    , CAST(item_value AS decimal(38,0))                  AS item_value
    , CAST(note AS string)                               AS note
    , CAST(disclosure_person_name AS string)             AS disclosure_person_name
    , CAST(disclosure_date AS timestamp)                 AS disclosure_date
    , CAST(attachment_path AS string)                    AS attachment_path
    , CAST(error_description AS string)                  AS error_description
    , CAST(created_by AS bigint)                         AS created_by
    , CAST(created_at AS timestamp)                      AS created_at
    , CAST(last_modified_by_legacy AS bigint)            AS last_modified_by_legacy
    , CAST(last_modified_at_legacy AS timestamp)         AS last_modified_at_legacy
    , CAST(sent_at AS timestamp)                         AS sent_at
    , CAST(record_status AS int)                         AS record_status
    , CAST(matter AS int)                                AS matter
    , CAST(legacy_filename AS string)                    AS legacy_filename
    , CAST(legacy_filedata AS string)                    AS legacy_filedata
    , CAST(legacy_rowtext AS string)                     AS legacy_rowtext
    , CAST(event_type_id AS bigint)                      AS event_type_id
    , CAST(expected_end_date AS date)                    AS expected_end_date
    , CAST(expected_start_date AS date)                  AS expected_start_date
    , CAST(synced_from_admin_proc AS int)                AS synced_from_admin_proc
    , CAST(result_attachment_path AS string)             AS result_attachment_path
    , CAST(document_file_path AS string)                 AS document_file_path
    , CAST(offering_price AS decimal(38,2))              AS offering_price
    , CAST(result_json AS string)                        AS result_json
    , CAST(offering_type AS bigint)                      AS offering_type
    , CAST(securities_type AS string)                    AS securities_type
    , CAST(offering_purpose AS string)                   AS offering_purpose
    , CAST(result_report_date AS date)                   AS result_report_date
    , CAST(start_date AS date)                           AS start_date
    , CAST(offering_start_date AS date)                  AS offering_start_date
    , CAST(offering_end_date AS date)                    AS offering_end_date
    , CAST(last_modified_at AS timestamp)                AS last_modified_at
    , CAST(last_modified_by AS bigint)                   AS last_modified_by
    , CAST(data_source AS string)                        AS data_source
    , CAST(plan_json AS string)                          AS plan_json
    , CAST(capital_use_plan AS string)                   AS capital_use_plan
    , CAST(offered_quantity AS decimal(19,0))            AS offered_quantity
    , CAST(underwriter AS string)                        AS underwriter
    , CAST(advisor AS string)                            AS advisor
    , CAST(total_value AS decimal(38,2))                 AS total_value
    , CAST(total_offered_quantity AS decimal(19,0))      AS total_offered_quantity
    , CAST(total_offered_completed AS decimal(19,0))     AS total_offered_completed
    , CAST(expected_total_amount AS decimal(38,2))       AS expected_total_amount
    , CAST(proceeds_collected AS decimal(38,2))          AS proceeds_collected
    , CAST(admin_proc_id AS bigint)                      AS admin_proc_id
    , CAST(extension_to_date AS date)                    AS extension_to_date
    , CAST(assessment AS string)                         AS assessment
    , CAST(underwriting_company AS string)               AS underwriting_company
    , CAST(capital_use_result_json AS string)            AS capital_use_result_json
    , CAST(item_category AS string)                      AS item_category
    , CAST(bond_type AS string)                          AS bond_type
    , CAST(bond_face_value AS decimal(20,2))             AS bond_face_value
    , CAST(bond_code AS string)                          AS bond_code
    , CAST(maturity_years AS bigint)                     AS maturity_years
    , CAST(interest_payment_period AS string)            AS interest_payment_period
    , CAST(bond_holder_representative AS string)         AS bond_holder_representative
    , CAST(collateral_required AS int)                   AS collateral_required
    , CAST(issuance_date AS date)                        AS issuance_date
    , CAST(covered_warrant_type AS string)               AS covered_warrant_type
    , CAST(covered_warrant_name AS string)               AS covered_warrant_name
    , CAST(listed_cw_code AS string)                     AS listed_cw_code
    , CAST(underlying_securities_code AS string)         AS underlying_securities_code
    , CAST(underlying_securities_issuer AS string)       AS underlying_securities_issuer
    , CAST(first_dossier_submission_date AS date)        AS first_dossier_submission_date
    , CAST(complete_dossier_submission_date AS date)     AS complete_dossier_submission_date
    , CAST(cw_registered_quantity AS decimal(19,0))      AS cw_registered_quantity
    , CAST(conversion_ratio AS decimal(19,0))            AS conversion_ratio
    , CAST(converted_shares_quantity AS decimal(19,0))   AS converted_shares_quantity
    , CAST(registered_offering_price AS decimal(20,2))   AS registered_offering_price
    , CAST(cw_term_months AS bigint)                     AS cw_term_months
    , CAST(collateral_settlement_value AS decimal(20,2)) AS collateral_settlement_value
    , CAST(collateral_deposit_bank AS string)            AS collateral_deposit_bank
    , CAST(cw_permitted_quantity AS decimal(19,0))       AS cw_permitted_quantity
    , CAST(cw_shares_per_warrant AS decimal(19,0))       AS cw_shares_per_warrant
    , CAST(cw_distributed_quantity AS decimal(19,0))     AS cw_distributed_quantity
    , CAST(cw_actual_offering_price AS decimal(20,2))    AS cw_actual_offering_price
    , CAST(cw_offering_date AS date)                     AS cw_offering_date
    , CAST(cw_maturity_date AS date)                     AS cw_maturity_date
    , CAST(cw_deposit_amount AS decimal(20,2))           AS cw_deposit_amount
    , CAST(cw_proceeds AS decimal(20,2))                 AS cw_proceeds
FROM {{ source('source_scms', 'raw_disclosure_securities_offering') }}