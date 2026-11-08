-- ────────────────────────────────────────────────────────────
-- Model : tknb_fct_covered_warrant_outstanding_snpst
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT
        snpst_dt_dim_id,
        security_trading_snpst_dim_id,
        outstanding_quantity,
        src_stm_code
    FROM {{ ref('dtm_fct_covered_warrant_outstanding_snpst') }}
    WHERE to_date(snpst_dt_dim_id, 'yyyyMMdd') = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

dim_security_trading AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol,
        security_full_nm
    FROM {{ ref('dtm_security_trading_snpst_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
)

SELECT
    f.snpst_dt_dim_id,
    f.security_trading_snpst_dim_id,
    f.outstanding_quantity,
    f.src_stm_code,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt,
    dim.symbol,
    dim.security_full_nm
FROM fact f
LEFT JOIN dim_security_trading dim
    ON f.security_trading_snpst_dim_id = dim.security_trading_snpst_dim_id
