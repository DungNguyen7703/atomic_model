/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_offering
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
        pc_code,
        official_letter_dt,
        certificate_dt,
        total_expected_amt
    FROM {{ ref('atm_pc_securities_offering') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING'
        and deleted_indicator = 0
        and approval_status_code = 'APPROVED'

),

pc_se_of_res_agg AS (
    SELECT
        pc_securities_offering_id,
        SUM(total_collected_amt) AS total_collected_amt
    FROM {{ ref('atm_pc_securities_offering_result') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING_RESULT'
        AND deleted_indicator = 0
        and offering_method_code_snpst NOT IN ('6','7','8','9')
    GROUP BY pc_securities_offering_id
    
)

SELECT
    CAST(pc_se_of.pc_securities_offering_code AS string)                                               AS securities_offering_code,
    date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')                 AS snpst_dt_dim_id,
    date_format(pc_se_of.certificate_dt, 'yyyyMMdd')                   AS certificate_dt_dim_id,
    CAST(pcd.public_company_dim_id AS string)                                                          AS public_company_dim_id,
    CAST(pc_se_of.total_expected_amt AS decimal(25,0))                                                         AS total_expected_amt,
    CAST(pc_se_of_res_agg.total_collected_amt AS decimal(25,0))                                                AS total_collected_amt,
    CAST(pc_se_of.official_letter_dt AS date)                                                          AS official_letter_dt
FROM pc_se_of
inner JOIN {{ ref('dtm_public_company_dim') }}_hstr pcd
    ON pcd.public_company_code = pc_se_of.pc_code
    AND pcd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND pcd.ds_rcrd_st = 'ACTIVE'
inner JOIN pc_se_of_res_agg
    ON pc_se_of_res_agg.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
