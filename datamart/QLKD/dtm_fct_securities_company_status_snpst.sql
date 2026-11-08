/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_company_status_snpst
* Program name: Dtm Fct Securities Company Status Snpst
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		claude			[SUA theo LLD] identification_tp_code sai
*                                       literal 'OPERATION_LICENSE' -> dung
*                                       'BUSINESS_LICENSE' (atomic chi sinh ra
*                                       gia tri nay cho SCMS_SC_FIRM_INFO; FK
*                                       truoc day luon NULL). Bo sung filter
*                                       src_stm_code = 'SCMS_SC_FIRM_INFO'
*                                       theo dung LOOKUP condition trong LLD.
*--------------------------------------------------------------------*
*/

WITH se_co AS (
    SELECT
        sc_id,
        sc_code,
        added_sc_id
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
),

ip_al_id AS (
    SELECT
        ip_id,
        identification_issue_dt
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'BUSINESS_LICENSE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
),

cd_dt_sn AS (
    SELECT
        cdr_dt_dim_id,
        cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
),

cd_dt_lic AS (
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
    CAST(cd_dt_sn.cdr_dt_dim_id AS string)             AS snpst_dt_dim_id,
    CAST(se_co_di.securities_company_dim_id AS string) AS securities_company_dim_id,
    date_format(ip_al_id.identification_issue_dt, 'yyyyMMdd') AS license_issue_dt_dim_id,
    CAST(se_co.added_sc_id as bigint) as added_sc_id
FROM se_co
LEFT JOIN se_co_di
    ON  se_co_di.sc_code = se_co.sc_code
LEFT JOIN ip_al_id
    ON  ip_al_id.ip_id = se_co.sc_id
LEFT JOIN cd_dt_sn
    ON  cd_dt_sn.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
-- LEFT JOIN cd_dt_lic
--     ON  cd_dt_lic.cdr_dt = ip_al_id.identification_issue_dt
