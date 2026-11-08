/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_company_brokerage_market_share_snpst
* Program name: Dtm Fct Securities Company Brokerage Market Share Snpst
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH br_ms AS (
    SELECT
        sc_member_code,
        src_stm_code,
        security_tp_code,
        report_quarter,
        sc_nm,
        market_share_by_value
    FROM {{ ref('atm_brokerage_market_share') }}
),

se_co_di AS (
    SELECT
        securities_company_dim_id,
        sc_code
    FROM {{ ref('dtm_securities_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

cd_dt_di AS (
    SELECT
        cdr_dt_dim_id,
        cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
)

SELECT
    CAST(cd_dt_di.cdr_dt_dim_id AS string)              AS snpst_dt_dim_id,
    CAST(se_co_di.securities_company_dim_id AS string)  AS securities_company_dim_id,
    CAST(br_ms.report_quarter AS string)                AS report_quarter,
    CAST(
        CASE
            WHEN br_ms.src_stm_code = 'HOSE_BROKERAGE_MARKET_SHARE' THEN 'HOSE - CP niêm yết'
            WHEN br_ms.src_stm_code = 'HNX_BROKERAGE_MARKET_SHARE' AND br_ms.security_tp_code LIKE '%CP NY%' THEN 'HNX - CP niêm yết'
            WHEN br_ms.src_stm_code = 'HNX_BROKERAGE_MARKET_SHARE' AND br_ms.security_tp_code LIKE '%UPCoM%' THEN 'UPCOM - CP đăng ký giao dịch'
            WHEN br_ms.src_stm_code = 'HNX_BROKERAGE_MARKET_SHARE' AND br_ms.security_tp_code LIKE '%TTCKPS%' THEN 'HNX - Chứng khoán phái sinh'
        END AS string)                                   AS trading_venue_nm,
    CAST(br_ms.sc_nm AS string)                          AS broker_nm,
    CAST(br_ms.market_share_by_value AS decimal(22,14))   AS market_share_pct,
    CAST(br_ms.src_stm_code AS string)                  AS src_stm_code
FROM br_ms
LEFT JOIN se_co_di
    ON  se_co_di.sc_code = br_ms.sc_member_code
LEFT JOIN cd_dt_di
    ON  cd_dt_di.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
