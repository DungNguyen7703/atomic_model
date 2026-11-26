/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_offering (dash1)
* Program name: Fact Securities Offering
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
        pc_securities_offering_id,
        pc_securities_offering_code,
        pc_id,
        pc_code,
        official_letter_dt,
        certificate_dt,
        total_expected_amt
    FROM {{ ref('atm_pc_securities_offering') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING'
        and deleted_ind = 0
        and approval_status_code = 'APPROVED'

),
pc_se_of_plan_agg as(
    SELECT
        pc_securities_offering_id,
        pc_securities_offering_code, -- [Modified: thêm pc_securities_offering_code vào SELECT và GROUP BY để JOIN clickhouse]
        sum(
        CASE
        	WHEN (offering_price = 0 OR offering_price IS NULL) THEN par_val*total_registered_quantity_snpst
        	ELSE total_expected_amt_snpst
        END) AS total_expected_amt
    FROM {{ ref('atm_pc_securities_offering_plan') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING_PLAN'
        and deleted_ind = 0
       -- and offering_method_code NOT IN ('6','7','8','10')
    GROUP BY pc_securities_offering_id, pc_securities_offering_code -- [Modified: thêm pc_securities_offering_code]
),

pc_se_of_res_agg AS (
    SELECT
        pc_securities_offering_id,
        security_tp_code,
        sum (CASE 
        	WHEN (actual_offering_price = 0 OR actual_offering_price IS NULL) THEN 10000 * total_successful_quantity
        	ELSE total_collected_amt
        END) AS total_collected_amt
    FROM {{ ref('atm_pc_securities_offering_result') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING_RESULT'
        AND deleted_ind = 0
        --and offering_method_code_snpst NOT IN ('6','7','8','10')
    GROUP BY pc_securities_offering_id, security_tp_code
)

SELECT
    CAST(pc_se_of.pc_securities_offering_code AS string)                                               AS securities_offering_code,
    clv2.cl_nm as security_tp_nm,
    --date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')                 AS snpst_dt_dim_id,
    date_format(pc_se_of.official_letter_dt, 'yyyyMMdd')               AS official_letter_dt_dim_id,
    date_format(pc_se_of.certificate_dt, 'yyyyMMdd')                   AS certificate_dt_dim_id,
    CAST(pcd.public_company_dim_id AS string)                                                          AS public_company_dim_id,
    --pc_id as public_company_dim_id,
    CAST(pc_se_of_plan_agg.total_expected_amt AS decimal(25,0))                                                         AS total_expected_amt,
    CAST(pc_se_of_res_agg.total_collected_amt AS decimal(25,0))                                                AS total_collected_amt
FROM pc_se_of
LEFT JOIN {{ ref('dtm_public_company_dim') }}_hstr pcd
    ON pcd.public_company_code = pc_se_of.pc_code
    and pcd.src_stm_code = 'IDS_COMPANY_PROFILES'
    AND pcd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND pcd.ds_rcrd_st = 'ACTIVE' --chỗ này hỏi lại Dũng
inner JOIN pc_se_of_res_agg
    ON pc_se_of_res_agg.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
inner JOIN pc_se_of_plan_agg
    ON pc_se_of_plan_agg.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
LEFT JOIN atomic.uat_atm.cl_value clv2
    ON clv2.cl_code = pc_se_of_res_agg.security_tp_code
    AND clv2.schema_code = 'SO_SECURITY_TYPE'

-- WITH pc_se_of AS (
--     SELECT
--         pc_securities_offering_id,
--         pc_securities_offering_code,
--         pc_id,
--         pc_code,
--         official_letter_dt,
--         certificate_dt,
--         total_expected_amt
--     FROM {{ ref('atm_pc_securities_offering') }}_hstr
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
--         AND ds_rcrd_st = 'ACTIVE'
--         AND src_stm_code = 'IDS_SECURITIES_OFFERING'
--         and deleted_ind = 0
--         and approval_status_code = 'APPROVED'

-- ),
-- pc_se_of_plan_agg as(
--     SELECT
--         pc_securities_offering_id,
--         pc_securities_offering_code, -- [Modified: thêm pc_securities_offering_code vào SELECT và GROUP BY để JOIN clickhouse]
--         sum(
--         CASE
--         	WHEN (offering_price = 0 OR offering_price IS NULL) THEN par_val*total_registered_quantity_snpst
--         	ELSE total_expected_amt_snpst
--         END) AS total_expected_amt
--     FROM {{ ref('atm_pc_securities_offering_plan') }}_hstr
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
--         AND ds_rcrd_st = 'ACTIVE'
--         AND src_stm_code = 'IDS_SECURITIES_OFFERING_PLAN'
--         and deleted_ind = 0
--        -- and offering_method_code NOT IN ('6','7','8','10')
--     GROUP BY pc_securities_offering_id, pc_securities_offering_code -- [Modified: thêm pc_securities_offering_code]
-- ),

-- pc_se_of_res_agg AS (
--     SELECT
--         pc_securities_offering_id,
--         security_tp_code,
--         sum (CASE 
--         	WHEN (actual_offering_price = 0 OR actual_offering_price IS NULL) THEN 10000 * total_successful_quantity
--         	ELSE total_collected_amt
--         END) AS total_collected_amt
--     FROM {{ ref('atm_pc_securities_offering_result') }}_hstr
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
--         AND ds_rcrd_st = 'ACTIVE'
--         AND src_stm_code = 'IDS_SECURITIES_OFFERING_RESULT'
--         AND deleted_ind = 0
--         --and offering_method_code_snpst NOT IN ('6','7','8','10')
--     GROUP BY pc_securities_offering_id, security_tp_code
-- )

-- SELECT
--     CAST(pc_se_of.pc_securities_offering_code AS string)                                               AS securities_offering_code,
--     clv2.cl_nm as security_tp_nm,
--     date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')                 AS snpst_dt_dim_id,
--     date_format(pc_se_of.certificate_dt, 'yyyyMMdd')                   AS certificate_dt_dim_id,
--     --CAST(pcd.public_company_dim_id AS string)                                                          AS public_company_dim_id,
--     pc_id as public_company_dim_id,
--     CAST(pc_se_of_plan_agg.total_expected_amt AS decimal(25,0))                                                         AS total_expected_amt,
--     CAST(pc_se_of_res_agg.total_collected_amt AS decimal(25,0))                                                AS total_collected_amt,
--     CAST(pc_se_of.official_letter_dt AS date)                                                          AS official_letter_dt
-- FROM pc_se_of
-- -- LEFT JOIN {{ ref('dtm_public_company_dim') }}_hstr pcd
-- --     ON pcd.public_company_code = pc_se_of.pc_code
-- --     AND pcd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
-- --     AND pcd.ds_rcrd_st = 'ACTIVE'
-- inner JOIN pc_se_of_res_agg
--     ON pc_se_of_res_agg.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
-- inner JOIN pc_se_of_plan_agg
--     ON pc_se_of_plan_agg.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
-- LEFT JOIN atomic.uat_atm.cl_value clv2
--     ON clv2.cl_code = pc_se_of_res_agg.security_tp_code
--     AND clv2.schema_code = 'SO_SECURITY_TYPE'