/*
*--------------------------------------------------------------------*
* Program code: stg_fms_offering
* Program name: Staging FMS.OFFERING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                         AS id
    , HEX(sec_id)                                   AS sec_id
    , CAST(deleted AS int)                          AS deleted
    , CAST(tthc_name AS string)                     AS tthc_name
    , CAST(offering_type AS string)                 AS offering_type
    , CAST(securities_type AS string)               AS securities_type
    , CAST(securities_name AS string)               AS securities_name
    , CAST(par_value AS decimal(38,2))              AS par_value
    , CAST(quantity_offered AS decimal(38,0))       AS quantity_offered
    , CAST(offering_price AS decimal(38,2))         AS offering_price
    , CAST(total_registered_value AS decimal(38,2)) AS total_registered_value
    , CAST(purpose AS string)                       AS purpose
    , CAST(capital_usage_plan AS string)            AS capital_usage_plan
    , CAST(expected_start_date AS date)             AS expected_start_date
    , CAST(expected_end_date AS date)               AS expected_end_date
    , CAST(guarantor_org AS string)                 AS guarantor_org
    , CAST(advisory_org AS string)                  AS advisory_org
    , CAST(offering_method AS string)               AS offering_method
    , CAST(target_audience AS string)               AS target_audience
    , CAST(capital_purpose AS string)               AS capital_purpose
    , CAST(offering_start_date AS date)             AS offering_start_date
    , CAST(offering_end_date AS date)               AS offering_end_date
    , CAST(extended AS int)                         AS extended
    , CAST(actual_target AS string)                 AS actual_target
    , CAST(quantity_sold AS decimal(38,0))          AS quantity_sold
    , CAST(actual_price AS decimal(38,2))           AS actual_price
    , CAST(actual_total_value AS decimal(38,2))     AS actual_total_value
    , CAST(employee_count AS bigint)                AS employee_count
    , CAST(foreign_investor_count AS bigint)        AS foreign_investor_count
    , CAST(issuance_value AS decimal(38,2))         AS issuance_value
    , CAST(date_created AS timestamp)               AS date_created
    , CAST(created_by AS string)                    AS created_by
    , CAST(date_modified AS timestamp)              AS date_modified
    , CAST(modify_by AS string)                     AS modify_by
    , CAST(approval_document_no AS string)          AS approval_document_no
    , CAST(approval_document_date AS date)          AS approval_document_date
    , CAST(data_source AS string)                   AS data_source
    , CAST(affair_code AS string)                   AS affair_code
    , CAST(stock_class AS string)                   AS stock_class
    , CAST(tthc_external_id AS string)              AS tthc_external_id
    , CAST(approval_document_file_name AS string)   AS approval_document_file_name
    , CAST(report_result_date AS date)              AS report_result_date
    , CAST(extended_to_date AS date)                AS extended_to_date
    , CAST(assessment AS string)                    AS assessment
    , CAST(result_attachment_file AS string)        AS result_attachment_file
    , CAST(note_text AS string)                     AS note_text
    , CAST(bond_type AS string)                     AS bond_type
    , CAST(bond_term_years AS bigint)               AS bond_term_years
    , CAST(interest_payment_period AS string)       AS interest_payment_period
    , CAST(bondholder_representative AS string)     AS bondholder_representative
    , CAST(collateral_secured AS int)               AS collateral_secured
FROM {{ source('source_fms', 'raw_offering') }}