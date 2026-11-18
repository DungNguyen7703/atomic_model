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
        , processor_user_nm_snpst
        , src_stm_code
    FROM {{ ref('atm_pc_securities_offering') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING'
        and deleted_indicator = 0
        and approval_status_code = 'APPROVED'
),

pub_co AS (
    SELECT
        pc_code
        , pc_nm
        , equity_ticker_symbol
        , securities_tp_code
        , cl_ids_business_line_level_1_code AS business_line_level_1_code
        , cl_ids_business_line_level_1_id   AS business_line_level_1_id
        , exchange_code                     AS equity_listing_exchange_code
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
),

pc_se_of_pl AS (
    SELECT
        pc_securities_offering_id
        , offering_method_code
        , AVG(offering_price)                          AS offering_price
        , SUM(employee_quantity)                       AS employee_quantity
        , SUM(total_expected_amt_snpst)                AS total_expected_amt
        , SUM(total_registered_quantity_snpst)         AS total_registered_quantity
    FROM {{ ref('atm_pc_securities_offering_plan') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING_PLAN'
        and deleted_indicator = 0 
    GROUP BY pc_securities_offering_id, offering_method_code
),

pc_se_of_pl_rep AS (
    SELECT
        pc_securities_offering_id
        , MIN(offering_method_code) AS offering_method_code_representative
    FROM {{ ref('atm_pc_securities_offering_plan') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING_PLAN'
        and deleted_indicator = 0 
    GROUP BY pc_securities_offering_id
),

pc_se_of_res AS (
    SELECT
        pc_securities_offering_id
        , offering_method_code_snpst
        , SUM(total_successful_quantity)               AS total_successful_quantity
        , SUM(total_collected_amt)                     AS total_collected_amt
        , AVG(actual_offering_price)                   AS actual_offering_price
        , SUM(employee_quantity)                       AS employee_quantity
    FROM {{ ref('atm_pc_securities_offering_result') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING_RESULT'
        and deleted_indicator = 0 
    GROUP BY pc_securities_offering_id, offering_method_code_snpst
)

SELECT
    CAST(pc_se_of.pc_securities_offering_code AS string)                                                                                                       AS securities_offering_code
    , CAST(pc_se_of_pl.offering_method_code AS string)                                                                                                         AS offering_method_code
    , CAST(clv.cl_nm AS string)                                                                                                                                AS offering_method_nm
    , CAST(pub_co.pc_code AS string)                                                                                                                           AS public_company_code
    , CAST(pub_co.pc_nm AS string)                                                                                                                             AS public_company_nm
    , CAST(pub_co.equity_ticker_symbol AS string)                                                                                                              AS equity_ticker_symbol
    , CAST(pub_co.securities_tp_code AS string)                                                                                                                AS securities_tp_code
    , CAST(pc_se_of_pl.total_registered_quantity AS decimal(17,0))                                                                                                          AS total_registered_quantity
    , CAST(pc_se_of_pl.total_expected_amt AS decimal(25,0))                                                                                                               AS total_expected_amt
    , CAST(pc_se_of.certificate_nbr AS string)                                                                                                                 AS certificate_nbr
    , CAST(pc_se_of.certificate_dt AS date)                                                                                                                    AS certificate_dt
    , CAST(pc_se_of.official_letter_nbr AS string)                                                                                                             AS official_letter_nbr
    , CAST(pc_se_of.official_letter_dt AS date)                                                                                                                AS official_letter_dt
    , CAST(pc_se_of.offering_purpose AS string)                                                                                                               AS offering_purpose
    , CAST(pc_se_of.consulting_organization_nm AS string)                                                                                                      AS consulting_organization_nm
    , CAST(pc_se_of.audit_organization_nm AS string)                                                                                                           AS audit_organization_nm
    , CAST(pc_se_of.underwriting_organization_nm AS string)                                                                                                    AS underwriting_organization_nm
    , CAST(pc_se_of.credit_rating_organization_nm AS string)                                                                                                   AS credit_rating_organization_nm
    , CAST(pc_se_of.processor_user_nm_snpst AS string)                                                                                                         AS processor_user_nm_snpst
    , CAST(pub_co.business_line_level_1_code AS string)                                                                                                        AS business_line_level_1_code
    , CAST(cl_bl.cl_business_line_nm AS string)                                                                                                                AS classification_business_line_nm
    , CAST(pub_co.equity_listing_exchange_code AS string)                                                                                                      AS equity_listing_exchange_code
    , CAST(pc_se_of_res.total_successful_quantity AS decimal(17,0))                                                                                                      AS total_successful_quantity
    , CAST(pc_se_of_res.total_collected_amt AS decimal(25,0))                                                                                                          AS total_collected_amt
    , CAST(ROUND(CAST(pc_se_of_res.total_successful_quantity AS decimal(17,0)) / NULLIF(CAST(pc_se_of.total_registered_quantity AS decimal(17,0)), 0) * 100, 2) AS decimal(17,0))    AS successful_ratio_percentage
    , CAST(pc_se_of_pl.offering_price AS decimal(17,0))                                                                                                                AS offering_price
    , CAST(pc_se_of_pl.employee_quantity AS int)                                                                                                               AS employee_quantity
    , CAST(CASE WHEN pc_se_of_pl_rep.offering_method_code_representative = '5' THEN pub_co.pc_nm ELSE NULL END AS string)                                     AS swap_target
    , CAST(pc_se_of_res.actual_offering_price AS decimal(17,0))                                                                                                        AS actual_offering_price
    , CAST(pc_se_of_res.employee_quantity AS int)                                                                                                              AS employee_quantity_result
    , CAST(CASE WHEN pc_se_of_res.offering_method_code_snpst = '5' THEN pub_co.pc_nm ELSE NULL END AS string)                                                AS capital_src
    , CAST(pc_se_of.src_stm_code AS string)                                                                                                                    AS src_stm_code
FROM pc_se_of
inner JOIN pub_co
    ON pub_co.pc_code = pc_se_of.pc_code
left JOIN pc_se_of_pl
    ON pc_se_of_pl.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
left JOIN pc_se_of_res
    ON pc_se_of_res.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
    AND pc_se_of_res.offering_method_code_snpst = pc_se_of_pl.offering_method_code
inner JOIN pc_se_of_pl_rep
    ON pc_se_of_pl_rep.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
inner JOIN atomic.uat_atm.cl_value clv
    ON clv.cl_code = pc_se_of_pl.offering_method_code
    AND clv.schema_code = 'SO_OFFERING_METHOD'
inner JOIN {{ ref('atm_cl_business_line') }} cl_bl
    ON cl_bl.cl_business_line_id = pub_co.business_line_level_1_id