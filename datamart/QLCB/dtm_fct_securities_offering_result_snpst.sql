/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_offering_result
* Program name: Fact Securities Offering Result
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pc_se_of_res AS (
    SELECT
        pc_securities_offering_id,
        pc_securities_offering_code,
        offering_method_code_snpst,
        security_tp_code,
        sum (CASE 
        	WHEN (actual_offering_price = 0 OR actual_offering_price IS NULL) THEN 10000 * total_successful_quantity
        	ELSE total_collected_amt
        END) AS total_collected_amt -- [Modified: thêm sum() + GROUP BY để tránh fanout khi join]
    FROM {{ ref('atm_pc_securities_offering_result') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING_RESULT'
        AND deleted_ind = 0
    GROUP BY
        pc_securities_offering_id,
        pc_securities_offering_code,
        offering_method_code_snpst,
        security_tp_code
),

pc_se_of AS (
    SELECT
        pc_securities_offering_id,
        pc_code,
        certificate_dt, 
        official_letter_dt
    FROM {{ ref('atm_pc_securities_offering') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND deleted_ind = 0
        AND src_stm_code = 'IDS_SECURITIES_OFFERING'
        and approval_status_code = 'APPROVED'
)

SELECT
    CAST(pc_se_of_res.pc_securities_offering_code AS string)                                           AS securities_offering_code,
    case 
        when pc_se_of_res.security_tp_code like '%CP%' then 'Cổ phiếu'
        when pc_se_of_res.security_tp_code like '%TP%' then 'Trái phiếu' 
    end as security_tp_nm,
    --date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')                 AS snpst_dt_dim_id,
    date_format(pc_se_of.certificate_dt, 'yyyyMMdd')                   AS certificate_dt_dim_id,
    date_format(pc_se_of.official_letter_dt, 'yyyyMMdd')              AS official_letter_dt_dim_id,
    CAST(pcd.public_company_dim_id AS string)                                                          AS public_company_dim_id,
    CAST(omd.offering_method_dim_id AS string)                                                         AS offering_method_dim_id,
    CAST(pc_se_of_res.total_collected_amt AS decimal(25,0))                                                    AS total_collected_amt
FROM pc_se_of_res
INNER JOIN pc_se_of
    ON pc_se_of.pc_securities_offering_id = pc_se_of_res.pc_securities_offering_id
INNER JOIN {{ ref('dtm_public_company_dim') }}_hstr pcd
    ON pcd.public_company_code = pc_se_of.pc_code
    and pcd.src_stm_code = 'IDS_COMPANY_PROFILES'
    AND pcd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
   -- AND pcd.ds_rcrd_st = 'ACTIVE'
LEFT JOIN {{ ref('dtm_offering_method_dim') }} omd
    ON omd.offering_method_code = pc_se_of_res.offering_method_code_snpst

-- WITH pc_se_of_res AS (
--     SELECT
--         pc_securities_offering_id,
--         pc_securities_offering_code,
--         offering_method_code_snpst,
--         security_tp_code,
--         sum (CASE 
--         	WHEN (actual_offering_price = 0 OR actual_offering_price IS NULL) THEN 10000 * total_successful_quantity
--         	ELSE total_collected_amt
--         END) AS total_collected_amt -- [Modified: thêm sum() + GROUP BY để tránh fanout khi join]
--     FROM {{ ref('atm_pc_securities_offering_result') }}_hstr
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
--         AND ds_rcrd_st = 'ACTIVE'
--         AND src_stm_code = 'IDS_SECURITIES_OFFERING_RESULT'
--         AND deleted_ind = 0
--     GROUP BY
--         pc_securities_offering_id,
--         pc_securities_offering_code,
--         offering_method_code_snpst,
--         security_tp_code
-- ),

-- pc_se_of AS (
--     SELECT
--         pc_securities_offering_id,
--         pc_code,
--         certificate_dt, 
--         official_letter_dt
--     FROM {{ ref('atm_pc_securities_offering') }}_hstr
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
--         AND ds_rcrd_st = 'ACTIVE'
--         AND deleted_ind = 0
--         AND src_stm_code = 'IDS_SECURITIES_OFFERING'
--         and approval_status_code = 'APPROVED'
-- )

-- SELECT
--     CAST(pc_se_of_res.pc_securities_offering_code AS string)                                           AS securities_offering_code,
--     case when pc_se_of_res.security_tp_code like '%CP%' then 'Cổ phiếu'
--      when pc_se_of_res.security_tp_code like '%TP%' then 'Trái phiếu' end as security_tp_nm,
--     date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')                 AS snpst_dt_dim_id,
--     date_format(pc_se_of.certificate_dt, 'yyyyMMdd')                   AS certificate_dt_dim_id,
--     COALESCE(pc_se_of.certificate_dt, pc_se_of.official_letter_dt)              AS cdr_dt,
--     CAST(pcd.public_company_dim_id AS string)                                                          AS public_company_dim_id,
--     CAST(omd.offering_method_dim_id AS string)                                                         AS offering_method_dim_id,
--     CAST(pc_se_of_res.total_collected_amt AS decimal(25,0))                                                    AS total_collected_amt
-- FROM pc_se_of_res
-- INNER JOIN pc_se_of
--     ON pc_se_of.pc_securities_offering_id = pc_se_of_res.pc_securities_offering_id
-- INNER JOIN {{ ref('dtm_public_company_dim') }}_hstr pcd
--     ON pcd.public_company_code = pc_se_of.pc_code
--     AND pcd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
--    -- AND pcd.ds_rcrd_st = 'ACTIVE'

-- LEFT JOIN {{ ref('dtm_offering_method_dim') }} omd
--     ON omd.offering_method_code = pc_se_of_res.offering_method_code_snpst

