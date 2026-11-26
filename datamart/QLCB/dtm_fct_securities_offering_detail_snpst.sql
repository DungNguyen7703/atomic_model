WITH pc_se_of_pl AS (
    -- Tổng hợp phương án phát hành theo đợt
    SELECT
        pc_securities_offering_id,
        pc_securities_offering_code,
        offering_method_code,
        offering_price,
        par_val,
        sum(total_registered_quantity_snpst) AS total_registered_quantity,
        SUM(total_expected_amt_snpst)  AS total_expected_amt
    FROM {{ ref('atm_pc_securities_offering_plan') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING_PLAN'
        and deleted_ind = 0
    GROUP BY pc_securities_offering_id, offering_method_code, pc_securities_offering_code, offering_price, par_val
),
pc_se_of_res AS (
    -- Tổng hợp kết quả phát hành theo đợt
    SELECT 
        pc_securities_offering_id,
        pc_securities_offering_code,
        offering_method_code_snpst,
        security_tp_code,
        actual_offering_price,
        SUM(total_successful_quantity) AS total_successful_quantity,
        SUM(total_collected_amt)    AS total_collected_amt
    FROM {{ ref('atm_pc_securities_offering_result') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING_RESULT'
        and deleted_ind = 0
    GROUP BY pc_securities_offering_id, offering_method_code_snpst, pc_securities_offering_code, security_tp_code, actual_offering_price
),
pub_co AS (
    SELECT
        pc_code
        , pc_nm
        , equity_ticker_symbol
        , securities_tp_code
        , business_line_level_1_code
        , business_line_level_1_id
        , equity_listing_exchange_code
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        --AND ds_rcrd_st = 'ACTIVE'
        --and deleted_ind = 0
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
)
SELECT
    CAST(pc_se_of.pc_securities_offering_code AS string)                                                                                                       AS securities_offering_code
    , CAST(pub_co.pc_nm AS string)                                       AS public_company_nm
    , CAST(COALESCE(cl_bl.cl_ids_business_line_nm, 'Chưa phân ngành') AS string)                      AS classification_business_line_nm
    , CAST(pub_co.equity_ticker_symbol AS string)                        AS equity_ticker_symbol
    , CAST(pub_co.securities_tp_code AS string)                          AS securities_tp_code
    , cast(clv2.cl_nm as string)                                         AS securities_tp_nm           
    , CAST(pc_se_of.certificate_dt AS date)                              AS certificate_dt
    , CAST(pc_se_of.official_letter_dt as date)                         as official_letter_dt 
    , coalesce(pc_se_of.certificate_dt, pc_se_of.official_letter_dt)     as cdr_dt   
    , CAST(clv.cl_nm AS string)                                          AS offering_method_nm
    , CAST(pc_se_of.consulting_organization_nm AS string)                AS consulting_organization_nm
    , CAST(pc_se_of.audit_organization_nm AS string)                     AS audit_organization_nm
    , CAST(pc_se_of.underwriting_organization_nm AS string)              AS underwriting_organization_nm
    , CAST(pc_se_of.credit_rating_organization_nm AS string)             AS credit_rating_organization_nm
    , CAST(pc_se_of_pl.total_registered_quantity AS decimal(17,0))       AS total_registered_quantity
    , CAST(pc_se_of_res.total_successful_quantity AS decimal(17,0))      AS total_successful_quantity
    , CAST(CASE
        WHEN (pc_se_of_res.actual_offering_price = 0 OR pc_se_of_res.actual_offering_price IS NULL)
        THEN pc_se_of_pl.par_val * pc_se_of_res.total_successful_quantity
        ELSE pc_se_of_res.total_collected_amt
      END AS decimal(25,0))                                             AS total_collected_amt
    , CAST(CASE
        WHEN (pc_se_of_pl.offering_price = 0 OR pc_se_of_pl.offering_price IS NULL)
        THEN pc_se_of_pl.par_val * pc_se_of_pl.total_registered_quantity
        ELSE pc_se_of_pl.total_expected_amt
      END AS decimal(25,0))                                             AS total_expected_amt
    , CAST(ROUND(CAST(pc_se_of_res.total_successful_quantity AS decimal(17,0))/ NULLIF(CAST(pc_se_of_pl.total_registered_quantity AS decimal(17,0)), 0) * 100, 2) AS decimal(17,2)) AS successful_ratio_percentage
FROM {{ ref('atm_pc_securities_offering') }}_hstr pc_se_of
inner JOIN pub_co
    ON pub_co.pc_code = pc_se_of.pc_code
    AND pub_co.src_stm_code = 'IDS_COMPANY_PROFILES'
left JOIN pc_se_of_pl
    ON pc_se_of_pl.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
left JOIN pc_se_of_res
    ON pc_se_of_res.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
    AND pc_se_of_res.offering_method_code_snpst = pc_se_of_pl.offering_method_code
left JOIN atomic.uat_atm.cl_value clv
    ON clv.cl_code = pc_se_of_pl.offering_method_code
    AND clv.schema_code = 'SO_OFFERING_METHOD'
LEFT JOIN atomic.uat_atm.cl_value clv2
    ON clv2.cl_code = pc_se_of_res.security_tp_code
    AND clv2.schema_code = 'SO_SECURITY_TYPE'
LEFT JOIN uat_atm.cl_ids_business_line cl_bl
    ON cl_bl.cl_ids_business_line_id = pub_co.business_line_level_1_id
    AND cl_bl.ds_rcrd_st = 'ACTIVE'
WHERE pc_se_of.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND pc_se_of.ds_rcrd_st = 'ACTIVE'
    AND pc_se_of.src_stm_code = 'IDS_SECURITIES_OFFERING'
    AND pc_se_of.deleted_ind = 0
    AND pc_se_of.approval_status_code = 'APPROVED'


-- WITH pc_se_of_pl AS (
--     -- Tổng hợp phương án phát hành theo đợt
--     SELECT
--         pc_securities_offering_id,
--         pc_securities_offering_code,
--         offering_method_code,
--         offering_price,
--         par_val,
--         sum(total_registered_quantity_snpst) AS total_registered_quantity,
--         SUM(total_expected_amt_snpst)  AS total_expected_amt
--     FROM {{ ref('atm_pc_securities_offering_plan') }}_hstr
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
--         AND ds_rcrd_st = 'ACTIVE'
--         AND src_stm_code = 'IDS_SECURITIES_OFFERING_PLAN'
--         and deleted_ind = 0
--     GROUP BY pc_securities_offering_id, offering_method_code, pc_securities_offering_code, offering_price, par_val
-- ),
-- pc_se_of_res AS (
--     -- Tổng hợp kết quả phát hành theo đợt
--     SELECT 
--         pc_securities_offering_id,
--         pc_securities_offering_code,
--         offering_method_code_snpst,
--         security_tp_code,
--         actual_offering_price,
--         SUM(total_successful_quantity) AS total_successful_quantity,
--         SUM(total_collected_amt)    AS total_collected_amt
--     FROM {{ ref('atm_pc_securities_offering_result') }}_hstr
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
--         AND ds_rcrd_st = 'ACTIVE'
--         AND src_stm_code = 'IDS_SECURITIES_OFFERING_RESULT'
--         and deleted_ind = 0
--     GROUP BY pc_securities_offering_id, offering_method_code_snpst, pc_securities_offering_code, security_tp_code, actual_offering_price
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
--     FROM {{ ref('atm_public_company') }}_hstr
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
--         --AND ds_rcrd_st = 'ACTIVE'
--         --and deleted_ind = 0
--         AND src_stm_code = 'IDS_COMPANY_PROFILES'
-- )
-- SELECT
--     CAST(pc_se_of.pc_securities_offering_code AS string)                                                                                                       AS securities_offering_code
--     , CAST(pub_co.pc_nm AS string)                                       AS public_company_nm
--     , CAST(cl_bl.cl_ids_business_line_nm as string)                                AS classification_business_line_nm
--     , CAST(pub_co.equity_ticker_symbol AS string)                        AS equity_ticker_symbol
--     , CAST(pub_co.securities_tp_code AS string)                          AS securities_tp_code
--     , cast(clv2.cl_nm as string)                                         AS securities_tp_nm           
--     , CAST(pc_se_of.certificate_dt AS date)                              AS certificate_dt    
--     , CAST(clv.cl_nm AS string)                                          AS offering_method_nm
--     , CAST(pc_se_of.consulting_organization_nm AS string)                AS consulting_organization_nm
--     , CAST(pc_se_of.audit_organization_nm AS string)                     AS audit_organization_nm
--     , CAST(pc_se_of.underwriting_organization_nm AS string)              AS underwriting_organization_nm
--     , CAST(pc_se_of.credit_rating_organization_nm AS string)             AS credit_rating_organization_nm
--     , CAST(pc_se_of_pl.total_registered_quantity AS decimal(17,0))       AS total_registered_quantity
--     , CAST(pc_se_of_res.total_successful_quantity AS decimal(17,0))      AS total_successful_quantity
--     , CAST(CASE
--         WHEN (pc_se_of_res.actual_offering_price = 0 OR pc_se_of_res.actual_offering_price IS NULL)
--         THEN pc_se_of_pl.par_val * pc_se_of_res.total_successful_quantity
--         ELSE pc_se_of_res.total_collected_amt
--       END AS decimal(25,0))                                             AS total_collected_amt
--     , CAST(CASE
--         WHEN (pc_se_of_pl.offering_price = 0 OR pc_se_of_pl.offering_price IS NULL)
--         THEN pc_se_of_pl.par_val * pc_se_of_pl.total_registered_quantity
--         ELSE pc_se_of_pl.total_expected_amt
--       END AS decimal(25,0))                                             AS total_expected_amt
--     , coalesce(pc_se_of.certificate_dt, pc_se_of.official_letter_dt)     as cdr_dt
--     , CAST(ROUND(CAST(pc_se_of_res.total_successful_quantity AS decimal(17,0))/ NULLIF(CAST(pc_se_of_pl.total_registered_quantity AS decimal(17,0)), 0) * 100, 2) AS decimal(17,2)) AS successful_ratio_percentage
-- FROM {{ ref('atm_pc_securities_offering') }}_hstr pc_se_of
-- inner JOIN pub_co
--     ON pub_co.pc_code = pc_se_of.pc_code
-- left JOIN pc_se_of_pl
--     ON pc_se_of_pl.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
-- left JOIN pc_se_of_res
--     ON pc_se_of_res.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
--     AND pc_se_of_res.offering_method_code_snpst = pc_se_of_pl.offering_method_code
-- left JOIN atomic.uat_atm.cl_value clv
--     ON clv.cl_code = pc_se_of_pl.offering_method_code
--     AND clv.schema_code = 'SO_OFFERING_METHOD'
-- LEFT JOIN atomic.uat_atm.cl_value clv2
--     ON clv2.cl_code = pc_se_of_res.security_tp_code
--     AND clv2.schema_code = 'SO_SECURITY_TYPE'
-- LEFT JOIN uat_atm.cl_ids_business_line cl_bl
--     ON cl_bl.cl_ids_business_line_id = pub_co.business_line_level_1_id
--     AND cl_bl.ds_rcrd_st = 'ACTIVE'
-- WHERE pc_se_of.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
--     AND pc_se_of.ds_rcrd_st = 'ACTIVE'
--     AND pc_se_of.src_stm_code = 'IDS_SECURITIES_OFFERING'
--     AND pc_se_of.deleted_ind = 0
--     AND pc_se_of.approval_status_code = 'APPROVED'