/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_company_license_condition_snpst
* Program name: Dtm Fct Securities Company License Condition Snpst
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*                   tuan.nguyenvanb     sc_al_vi_all: processing_dt-->data_dt
*--------------------------------------------------------------------*
*/

WITH sc_al_vi_all AS (
    SELECT
        data_dt,
        sc_code,
        sc_alert_indicator_id,
        row_number() over (partition by sc_code order by data_dt desc) as rn
    FROM {{ ref('atm_sc_alert_violation') }}
    WHERE data_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

sc_al_vi AS (
    SELECT
        data_dt,
        sc_code,
        sc_alert_indicator_id
    FROM sc_al_vi_all
    WHERE rn = 1
),

sc_al_in AS (
    SELECT 
        sc_alert_indicator_id,
        indicator_code,
        severity_level
    FROM {{ ref('atm_sc_alert_indicator') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_ALERT_INDICATOR'
),

cd_dt_di AS (
    SELECT 
        cdr_dt_dim_id, 
        cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
),

se_co_di AS (
    SELECT 
        securities_company_dim_id, 
        sc_code
    FROM {{ ref('dtm_securities_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    CAST(cd_dt_di.cdr_dt_dim_id AS string)              AS snpst_dt_dim_id,
    CAST(se_co_di.securities_company_dim_id AS string)  AS securities_company_dim_id,
    CAST(sc_al_in.indicator_code AS string)             AS indicator_code,
    CAST(sc_al_in.severity_level AS string)             AS severity_level
FROM sc_al_vi
LEFT JOIN cd_dt_di
    ON  cd_dt_di.cdr_dt = sc_al_vi.data_dt
LEFT JOIN se_co_di
    ON  se_co_di.sc_code = sc_al_vi.sc_code
LEFT JOIN sc_al_in
    ON sc_al_in.sc_alert_indicator_id = sc_al_vi.sc_alert_indicator_id
