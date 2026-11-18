/*
*--------------------------------------------------------------------*
* Program code: dtm_securities_offering_360_profile
* Program name: Dtm Securities Offering 360 Profile
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pc_se_of AS (
    SELECT
        pc_securities_offering_id
        , pc_code
        , pc_securities_offering_code
        , total_registered_quantity
        , total_expected_amt
        , certificate_nbr
        , certificate_dt
        , official_letter_nbr
        , official_letter_dt
        , offering_purpose
        , consulting_organization_nm
        , audit_organization_nm
        , underwriting_organization_nm
        , credit_rating_organization_nm
        , CAST(NULL AS string) AS processor_user_nm_snpst
        , src_stm_code
        , submission_dt
    FROM {{ ref('atm_pc_securities_offering') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING'
        AND approval_status_code = 'APPROVED'
),
pub_co AS (
    SELECT
        pc_code
        , pc_nm
        , equity_ticker_symbol
        , securities_tp_code
        , cl_ids_business_line_level_1_code AS business_line_level_1_code
        , cl_ids_business_line_level_1_id AS business_line_level_1_id
        , exchange_code AS equity_listing_exchange_code
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        --AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        --AND deleted_ind = 0
),
pc_se_of_pl AS (
    SELECT
        pc_securities_offering_id
        , offering_method_code
        , swap_target
        , single_offering_object
        , offering_price
        , SUM(employee_quantity)                       AS employee_quantity
        , SUM(total_expected_amt)                      AS total_expected_amt
        , SUM(total_registered_quantity)               AS total_registered_quantity
    FROM {{ ref('atm_pc_securities_offering_plan') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING_PLAN'
    GROUP BY pc_securities_offering_id, offering_method_code, swap_target, single_offering_object, offering_price
),
pc_se_of_res AS (
    SELECT
        pc_securities_offering_id
        , result_rpt_dt                                AS result_report_date
        , offering_method_code
        , result_single_object
        , security_tp_code                             AS security_type_code
        , offering_end_dt                              AS offering_end_date
        , SUM(total_successful_quantity)               AS total_successful_quantity
        , SUM(total_collected_amt)                     AS total_collected_amt
        , SUM(foreign_collected_amt)                   AS foreign_collected_amt
        , actual_offering_price
        , SUM(employee_quantity)                       AS employee_quantity
    FROM {{ ref('atm_pc_securities_offering_result') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING_RESULT'
    GROUP BY pc_securities_offering_id, offering_method_code, result_single_object, actual_offering_price, result_rpt_dt, security_tp_code, offering_end_dt
)
SELECT
    pc_se_of_res.result_report_date as result_report_dt
    , CAST(clv2.cl_nm AS string)                                                                                         AS securities_tp_nm
    , pc_se_of_res.offering_end_date
    , pc_se_of_res.foreign_collected_amt
    , CAST(pc_se_of.submission_dt AS date)                                                                               AS submission_dt
    , CAST(pc_se_of.pc_securities_offering_code AS string)                                                               AS securities_offering_code
    , CAST(pc_se_of_pl.offering_method_code AS string)                                                                   AS offering_method_code
    , CAST(clv1.cl_nm AS string)                                                                                         AS offering_method_nm
    , CAST(pub_co.pc_code AS string)                                                                                     AS public_company_code
    , CAST(pub_co.pc_nm AS string)                                                                                       AS public_company_nm
    , CAST(pub_co.equity_ticker_symbol AS string)                                                                        AS equity_ticker_symbol
    , CAST(pub_co.securities_tp_code AS string)                                                                          AS securities_tp_code
    , CAST(pc_se_of_pl.total_registered_quantity AS decimal(17,0))                                                       AS total_registered_quantity
    , CAST(pc_se_of_pl.total_expected_amt AS decimal(25,0))                                                              AS total_expected_amt
    , CAST(pc_se_of.certificate_nbr AS string)                                                                           AS certificate_nbr
    , CAST(pc_se_of.certificate_dt AS date)                                                                              AS certificate_dt
    , CAST(pc_se_of.official_letter_nbr AS string)                                                                       AS official_letter_nbr
    , CAST(pc_se_of.official_letter_dt AS date)                                                                          AS official_letter_dt
    , CAST(pc_se_of.offering_purpose AS string)                                                                          AS offering_purpose
    , CAST(pc_se_of.consulting_organization_nm AS string)                                                                AS consulting_organization_nm
    , CAST(pc_se_of.audit_organization_nm AS string)                                                                     AS audit_organization_nm
    , CAST(pc_se_of.underwriting_organization_nm AS string)                                                              AS underwriting_organization_nm
    , CAST(pc_se_of.credit_rating_organization_nm AS string)                                                             AS credit_rating_organization_nm
    , CAST(pc_se_of.processor_user_nm_snpst AS string)                                                                   AS processor_user_nm_snpst
    , CAST(pub_co.business_line_level_1_code AS string)                                                                  AS business_line_level_1_code
    , CAST(COALESCE(cl_bl.cl_ids_business_line_nm, 'Chưa phân ngành') AS string)                                            AS classification_business_line_nm -- [Modified: fallback 'Chưa phân ngành' khi không join được atm_cl_business_line]
    , CAST(pub_co.equity_listing_exchange_code AS string)                                                                AS equity_listing_exchange_code
    , CAST(pc_se_of_res.total_successful_quantity AS decimal(17,0))                                                      AS total_successful_quantity
    , CAST(pc_se_of_res.total_collected_amt AS decimal(25,0))                                                            AS total_collected_amt
--    , CAST(ROUND(CAST(pc_se_of_res.total_successful_quantity AS decimal(17,0))/ NULLIF(CAST(pc_se_of_pl.total_registered_quantity AS decimal(17,0)), 0) * 100, 0) AS decimal(17,0)) AS successful_ratio_percentage
    , CAST(pc_se_of_pl.offering_price AS decimal(17,0))                                                                  AS offering_price
    , CAST(pc_se_of_pl.employee_quantity AS int)                                                                         AS employee_quantity
    , CAST(CASE WHEN pc_se_of_pl.offering_method_code = '6' THEN pc_se_of_pl.swap_target ELSE pc_se_of_pl.single_offering_object END AS string)             AS licensed_object
    , CAST(CASE WHEN pc_se_of_res.offering_method_code = '6' THEN pc_se_of_pl.swap_target ELSE pc_se_of_res.result_single_object END AS string)       AS outcome_object
    , CAST(pc_se_of_res.actual_offering_price AS decimal(17,0))                                                          AS actual_offering_price
    , CAST(pc_se_of_res.employee_quantity AS int)                                                                        AS employee_quantity_result
    , CAST(CASE WHEN pc_se_of_res.offering_method_code = '5' THEN pub_co.pc_nm ELSE NULL END AS string)                 AS capital_src
    , CAST(pc_se_of.src_stm_code AS string)                                                                              AS src_stm_code
    , COALESCE(pc_se_of.certificate_dt, pc_se_of.official_letter_dt)                                                    AS cdr_dt
FROM pc_se_of
INNER JOIN pub_co
    ON pub_co.pc_code = pc_se_of.pc_code
LEFT JOIN pc_se_of_pl 
    ON pc_se_of_pl.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
LEFT JOIN pc_se_of_res
    ON pc_se_of_res.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
    AND pc_se_of_res.offering_method_code = pc_se_of_pl.offering_method_code
    AND pc_se_of_res.actual_offering_price = pc_se_of_pl.offering_price
LEFT JOIN {{ ref('atm_cl_value') }} clv1
    ON clv1.cl_code = pc_se_of_pl.offering_method_code
    AND clv1.schema_code = 'SO_OFFERING_METHOD'
LEFT JOIN {{ ref('atm_cl_value') }} clv2
    ON clv2.cl_code = pc_se_of_res.security_type_code
    AND clv2.schema_code = 'SO_SECURITY_TYPE'
LEFT JOIN {{ ref('atm_cl_ids_business_line') }} cl_bl
    ON cl_bl.cl_ids_business_line_id = pub_co.business_line_level_1_id
    AND cl_bl.ds_rcrd_st = 'ACTIVE'

-- WITH pc_se_of AS (
--     SELECT
--         pc_securities_offering_id
--         , pc_code
--         , pc_securities_offering_code
--         , total_registered_quantity
--         , total_expected_amt
--         , certificate_nbr
--         , certificate_dt
--         , official_letter_nbr
--         , official_letter_dt
--         , offering_purpose
--         , consulting_organization_nm
--         , audit_organization_nm
--         , underwriting_organization_nm
--         , credit_rating_organization_nm
--         , processor_user_nm_snpst
--         , src_stm_code
--         , submission_dt
--     FROM {{ ref('atm_pc_securities_offering') }}_hstr
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
--         AND ds_rcrd_st = 'ACTIVE'
--         AND src_stm_code = 'IDS_SECURITIES_OFFERING'
--         AND deleted_ind = 0
--         AND approval_status_code = 'APPROVED'
-- ),
-- pub_co AS (
--     SELECT
--         pc_code
--         , pc_nm
--         , equity_ticker_symbol
--         , securities_tp_code
--         , business_line_level_1_code
--         , business_line_level_1_id
--         , equity_listing_exchange_code
--         , deleted_ind
--     FROM {{ ref('atm_public_company') }}_hstr
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
--         AND ds_rcrd_st = 'ACTIVE'
--         AND src_stm_code = 'IDS_COMPANY_PROFILES'
--         --AND deleted_ind = 0
-- ),
-- pc_se_of_pl AS (
--     SELECT
--         pc_securities_offering_id
--         , offering_method_code
--         , swap_target
--         , single_offering_object
--         , offering_price
--         , SUM(employee_quantity)                       AS employee_quantity
--         , SUM(total_expected_amt_snpst)                AS total_expected_amt
--         , SUM(total_registered_quantity_snpst)         AS total_registered_quantity
--     FROM {{ ref('atm_pc_securities_offering_plan') }}_hstr
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
--         AND ds_rcrd_st = 'ACTIVE'
--         AND src_stm_code = 'IDS_SECURITIES_OFFERING_PLAN'
--         AND deleted_ind = 0
--     GROUP BY pc_securities_offering_id, offering_method_code, swap_target, single_offering_object, offering_price
-- ),
-- pc_se_of_res AS (
--     SELECT
--         pc_securities_offering_id
--         , result_rpt_dt                                AS result_report_date
--         , offering_method_code_snpst
--         , result_single_object
--         , security_tp_code                             AS security_type_code
--         , offering_end_dt                              AS offering_end_date
--         , SUM(total_successful_quantity)               AS total_successful_quantity
--         , SUM(total_collected_amt)                     AS total_collected_amt
--         , SUM(foreign_collected_amt)                   AS foreign_collected_amt
--         , actual_offering_price
--         , SUM(employee_quantity)                       AS employee_quantity
--     FROM {{ ref('atm_pc_securities_offering_result') }}_hstr
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
--         AND ds_rcrd_st = 'ACTIVE'
--         AND src_stm_code = 'IDS_SECURITIES_OFFERING_RESULT'
--         AND deleted_ind = 0
--     GROUP BY pc_securities_offering_id, offering_method_code_snpst, result_single_object, actual_offering_price, result_rpt_dt, security_tp_code, offering_end_dt
-- )
-- SELECT
--     pc_se_of_res.result_report_date as result_report_dt
--     , CAST(clv2.cl_nm AS string)                                                                                         AS securities_tp_nm
--     , pc_se_of_res.offering_end_date
--     , pc_se_of_res.foreign_collected_amt
--     , CAST(pc_se_of.submission_dt AS date)                                                                               AS submission_dt
--     , CAST(pc_se_of.pc_securities_offering_code AS string)                                                               AS securities_offering_code
--     , CAST(pc_se_of_pl.offering_method_code AS string)                                                                   AS offering_method_code
--     , CAST(clv1.cl_nm AS string)                                                                                         AS offering_method_nm
--     , CAST(pub_co.pc_code AS string)                                                                                     AS public_company_code
--     , CAST(pub_co.pc_nm AS string)                                                                                       AS public_company_nm
--     , CAST(pub_co.equity_ticker_symbol AS string)                                                                        AS equity_ticker_symbol
--     , CAST(pub_co.securities_tp_code AS string)                                                                          AS securities_tp_code
--     , CAST(pc_se_of_pl.total_registered_quantity AS decimal(17,0))                                                       AS total_registered_quantity
--     , CAST(pc_se_of_pl.total_expected_amt AS decimal(25,0))                                                              AS total_expected_amt
--     , CAST(pc_se_of.certificate_nbr AS string)                                                                           AS certificate_nbr
--     , CAST(pc_se_of.certificate_dt AS date)                                                                              AS certificate_dt
--     , CAST(pc_se_of.official_letter_nbr AS string)                                                                       AS official_letter_nbr
--     , CAST(pc_se_of.official_letter_dt AS date)                                                                          AS official_letter_dt
--     , CAST(pc_se_of.offering_purpose AS string)                                                                          AS offering_purpose
--     , CAST(pc_se_of.consulting_organization_nm AS string)                                                                AS consulting_organization_nm
--     , CAST(pc_se_of.audit_organization_nm AS string)                                                                     AS audit_organization_nm
--     , CAST(pc_se_of.underwriting_organization_nm AS string)                                                              AS underwriting_organization_nm
--     , CAST(pc_se_of.credit_rating_organization_nm AS string)                                                             AS credit_rating_organization_nm
--     , CAST(pc_se_of.processor_user_nm_snpst AS string)                                                                   AS processor_user_nm_snpst
--     , CAST(pub_co.business_line_level_1_code AS string)                                                                  AS business_line_level_1_code
--     , CAST(COALESCE(cl_bl.cl_business_line_nm, 'Chưa phân ngành') AS string)                                            AS classification_business_line_nm -- [Modified: fallback 'Chưa phân ngành' khi không join được atm_cl_business_line]
--     , CAST(pub_co.equity_listing_exchange_code AS string)                                                                AS equity_listing_exchange_code
--     , CAST(pc_se_of_res.total_successful_quantity AS decimal(17,0))                                                      AS total_successful_quantity
--     , CAST(pc_se_of_res.total_collected_amt AS decimal(25,0))                                                            AS total_collected_amt
-- --    , CAST(ROUND(CAST(pc_se_of_res.total_successful_quantity AS decimal(17,0))/ NULLIF(CAST(pc_se_of_pl.total_registered_quantity AS decimal(17,0)), 0) * 100, 0) AS decimal(17,0)) AS successful_ratio_percentage
--     , CAST(pc_se_of_pl.offering_price AS decimal(17,0))                                                                  AS offering_price
--     , CAST(pc_se_of_pl.employee_quantity AS int)                                                                         AS employee_quantity
--     , CAST(CASE WHEN pc_se_of_pl.offering_method_code = '6' THEN pc_se_of_pl.swap_target ELSE pc_se_of_pl.single_offering_object END AS string)             AS licensed_object
--     , CAST(CASE WHEN pc_se_of_res.offering_method_code_snpst = '6' THEN pc_se_of_pl.swap_target ELSE pc_se_of_res.result_single_object END AS string)       AS outcome_object
--     , CAST(pc_se_of_res.actual_offering_price AS decimal(17,0))                                                          AS actual_offering_price
--     , CAST(pc_se_of_res.employee_quantity AS int)                                                                        AS employee_quantity_result
--     , CAST(CASE WHEN pc_se_of_res.offering_method_code_snpst = '5' THEN pub_co.pc_nm ELSE NULL END AS string)           AS capital_src
--     , CAST(pc_se_of.src_stm_code AS string)                                                                              AS src_stm_code
--     , COALESCE(pc_se_of.certificate_dt, pc_se_of.official_letter_dt)                                                    AS cdr_dt
-- FROM pc_se_of
-- inner JOIN pub_co
--     ON pub_co.pc_code = pc_se_of.pc_code
-- LEFT JOIN pc_se_of_pl
--     ON pc_se_of_pl.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
-- LEFT JOIN pc_se_of_res
--     ON pc_se_of_res.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
--     AND pc_se_of_res.offering_method_code_snpst = pc_se_of_pl.offering_method_code
-- LEFT JOIN atomic.uat_atm.cl_value clv1
--     ON clv1.cl_code = pc_se_of_pl.offering_method_code
--     AND clv1.schema_code = 'SO_OFFERING_METHOD'
-- LEFT JOIN atomic.uat_atm.cl_value clv2
--     ON clv2.cl_code = pc_se_of_res.security_type_code
--     AND clv2.schema_code = 'SO_SECURITY_TYPE'
-- LEFT JOIN {{ ref('atm_cl_ids_business_line') }} cl_bl
--     ON cl_bl.cl_business_line_id = pub_co.business_line_level_1_id
--     AND cl_bl.deleted_ind = 0

