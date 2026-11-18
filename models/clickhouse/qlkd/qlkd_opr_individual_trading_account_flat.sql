-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_individual_trading_account_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Individual Trading Account
    o.sc_shareholder_code,
    o.sc_code,
    o.sc_short_nm,
    o.individual_identification_nbr,
    o.trading_account,
    o.shareholder_nm,
    o.shareholder_tp_code,
    o.src_stm_code,
    o.created_dt

FROM {{ ref('dtm_opr_individual_trading_account') }} o