/*
*--------------------------------------------------------------------*
* Program code: atm_fmc_securities_offering
* Program name: Atomic Fund Management Company Securities Offering
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-21		tuan.nguyenvanb		[LLD lld_FMS_OFFERING.yaml (approved)] Dung lai atomic (truoc day da xoa theo LLD FMS). scd4a, unique_key fmc_securities_offering_id.
*--------------------------------------------------------------------*
*/

-- Bo ban ghi da xoa mem o nguon (FMS.OFFERING.DELETED = 1): LLD khong map cot DELETED (pending_design) nhung model mart cong
-- tong huy dong von nen khong duoc tinh dot da bi xoa.
WITH ofr AS (
    SELECT
        id
        , sec_id
        , tthc_name
        , offering_type
        , securities_type
        , securities_name
        , par_value
        , quantity_offered
        , offering_price
        , total_registered_value
        , purpose
        , capital_usage_plan
        , expected_start_date
        , expected_end_date
        , guarantor_org
        , advisory_org
        , offering_method
        , target_audience
        , capital_purpose
        , offering_start_date
        , offering_end_date
        , extended
        , actual_target
        , quantity_sold
        , actual_price
        , actual_total_value
        , employee_count
        , foreign_investor_count
        , issuance_value
        , approval_document_no
        , approval_document_date
        , data_source
        , affair_code
        , stock_class
        , tthc_external_id
        , report_result_date
        , extended_to_date
        , assessment
        , note_text
        , bond_type
        , bond_term_years
        , interest_payment_period
        , bondholder_representative
        , collateral_secured
    FROM {{ ref('ods_fms_offering') }}
    WHERE COALESCE(deleted, 0) = 0
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_OFFERING', "ofr.id") }}                    AS fmc_securities_offering_id
    , CAST(ofr.id AS string)                                                         AS fmc_securities_offering_code
    , CAST('FMS_OFFERING' AS string)                                                 AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_SECURITIES', "ofr.sec_id") }}            AS fmc_id
    , CAST(ofr.sec_id AS string)                                                     AS fmc_code
    , CAST(ofr.tthc_name AS string)                                                  AS tthc_application_nm
    , CAST(ofr.offering_type AS string)                                              AS offering_tp_code
    , CAST(ofr.securities_type AS string)                                            AS securities_tp_code
    , CAST(ofr.securities_name AS string)                                            AS securities_nm
    , CAST(ofr.par_value AS decimal(23,2))                                           AS unit_par_val_amt
    , CAST(ofr.quantity_offered AS bigint)                                           AS offered_quantity
    , CAST(ofr.offering_price AS decimal(23,2))                                      AS offering_price_amt
    , CAST(ofr.total_registered_value AS decimal(23,2))                              AS total_registered_val_amt
    , CAST(ofr.purpose AS string)                                                    AS purpose_description
    , CAST(ofr.capital_usage_plan AS string)                                         AS capital_usage_plan_description
    , CAST(ofr.expected_start_date AS date)                                          AS expected_start_dt
    , CAST(ofr.expected_end_date AS date)                                            AS expected_end_dt
    , CAST(ofr.guarantor_org AS string)                                              AS guarantor_organization_nm
    , CAST(ofr.advisory_org AS string)                                               AS advisory_organization_nm
    , CAST(ofr.offering_method AS string)                                            AS offering_method_description
    , CAST(ofr.target_audience AS string)                                            AS target_audience_description
    , CAST(ofr.capital_purpose AS string)                                            AS capital_purpose_code
    , CAST(ofr.offering_start_date AS date)                                          AS offering_start_dt
    , CAST(ofr.offering_end_date AS date)                                            AS offering_end_dt
    , CAST(ofr.extended AS int)                                                      AS extended_flag
    , CAST(ofr.actual_target AS string)                                              AS actual_target_description
    , CAST(ofr.quantity_sold AS bigint)                                              AS sold_quantity
    , CAST(ofr.actual_price AS decimal(23,2))                                        AS actual_price_amt
    , CAST(ofr.actual_total_value AS decimal(23,2))                                  AS actual_total_val_amt
    , CAST(ofr.employee_count AS int)                                                AS employee_participant_count
    , CAST(ofr.foreign_investor_count AS int)                                        AS foreign_investor_participant_count
    , CAST(ofr.issuance_value AS decimal(23,2))                                      AS issuance_val_amt
    , CAST(ofr.approval_document_no AS string)                                       AS approval_document_nbr
    , CAST(ofr.approval_document_date AS date)                                       AS approval_document_dt
    , CAST(ofr.data_source AS string)                                                AS data_src_code
    , CAST(ofr.affair_code AS string)                                                AS affair_code
    , CAST(ofr.stock_class AS string)                                                AS stock_class_code
    , CAST(ofr.tthc_external_id AS string)                                           AS tthc_external_reference_id
    , CAST(ofr.report_result_date AS date)                                           AS rpt_result_dt
    , CAST(ofr.extended_to_date AS date)                                             AS extended_to_dt
    , CAST(ofr.assessment AS string)                                                 AS assessment_description
    , CAST(ofr.note_text AS string)                                                  AS note_text
    , CAST(ofr.bond_type AS string)                                                  AS bond_tp_code
    , CAST(ofr.bond_term_years AS int)                                               AS bond_term_years
    , CAST(ofr.interest_payment_period AS string)                                    AS interest_payment_period_description
    , CAST(ofr.bondholder_representative AS string)                                  AS bondholder_representative_nm
    , CAST(ofr.collateral_secured AS int)                                            AS collateral_secured_flag
FROM ofr
