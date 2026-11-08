/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_offering_application
* Program name: Dtm Fct Securities Offering Application
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
        approval_status_code,
        certificate_dt,
        application_code AS application_cd
    FROM {{ ref('atm_pc_securities_offering') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_SECURITIES_OFFERING'
        and deleted_indicator = 0
        and approval_status_code = 'APPROVED'
),

plan_first AS (
    SELECT
        pc_securities_offering_id,
        offering_method_code
    FROM (
        SELECT
            pc_securities_offering_id,
            offering_method_code
           -- ROW_NUMBER() OVER (PARTITION BY pc_securities_offering_id ORDER BY pc_securities_offering_plan_id) AS rn
        FROM {{ ref('atm_pc_securities_offering_plan') }}_hstr
        WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND ds_rcrd_st = 'ACTIVE'
            AND src_stm_code = 'IDS_SECURITIES_OFFERING_PLAN'
            AND deleted_indicator = 0
    )
    --WHERE rn = 1
)

SELECT
    CAST(pc_se_of.pc_securities_offering_code AS string)    AS securities_offering_code,
    CAST(pc_se_of.application_cd AS string)                 AS application_cd,
    date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')                 AS snpst_dt_dim_id,
    date_format(pc_se_of.certificate_dt, 'yyyyMMdd')                   AS certificate_dt_dim_id,
    CAST(pc_se_of.approval_status_code AS string)           AS application_status_code,
    CAST(omd.offering_method_dim_id AS string)              AS offering_method_dim_id

FROM pc_se_of
LEFT JOIN plan_first
    ON plan_first.pc_securities_offering_id = pc_se_of.pc_securities_offering_id
LEFT JOIN {{ ref('dtm_offering_method_dim') }} omd
    ON omd.offering_method_code = plan_first.offering_method_code
