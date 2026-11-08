/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_domestic_institution_net_trade_snpst
* Program name: Fact Domestic Institution Net Trade Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[TAO MOI theo BA top 10 gia tri rong To chuc trong nuoc] Fact Domestic Institution Net Trade theo ma CK/ngay, logic giong dtm_fct_proprietary_net_trade_snpst: SUM(execution_val), market_id_code IN ('STK','STX','UPX'), khong loc board. Nhom nha dau tu theo VSDC atm_open_investor_account.investor_tp_code = 5 (ban ghi moi nhat / so tai khoan theo open_dt DESC; nguon LLD 05c7c2d3 O_PTTT_51), noi qua buy_account_nbr (mua) va sell_account_nbr (ban). Bang moi nen can tao bang vat ly truoc khi chay (xem scratch/ddl_pttt_domestic_net_trade_20261106.sql).
*--------------------------------------------------------------------*
*/

WITH inv_acc AS (
    SELECT investor_account_nbr, investor_tp_code
    FROM (
        SELECT
            investor_account_nbr
            , investor_tp_code
            , ROW_NUMBER() OVER (PARTITION BY investor_account_nbr ORDER BY open_dt DESC) AS rn
        FROM {{ ref('atm_open_investor_account') }}
        WHERE investor_account_nbr IS NOT NULL
    ) x
    WHERE rn = 1
),

se_tr AS (
    SELECT
        t.trade_dt
        , t.security_symbol_code
        , t.execution_val
        , buy_inv.investor_tp_code  AS buy_vsdc_tp_code
        , sell_inv.investor_tp_code AS sell_vsdc_tp_code
    FROM {{ ref('atm_securities_trade') }} t
    LEFT JOIN inv_acc buy_inv
        ON buy_inv.investor_account_nbr = t.buy_account_nbr
    LEFT JOIN inv_acc sell_inv
        ON sell_inv.investor_account_nbr = t.sell_account_nbr
    WHERE t.trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND t.market_id_code IN ('STK','STX','UPX')
),

agg AS (
    SELECT
        se_tr.trade_dt
        , se_tr.security_symbol_code
        , SUM(CASE WHEN se_tr.buy_vsdc_tp_code = 5 THEN se_tr.execution_val ELSE 0 END)  AS domestic_institution_buy_val
        , SUM(CASE WHEN se_tr.sell_vsdc_tp_code = 5 THEN se_tr.execution_val ELSE 0 END) AS domestic_institution_sell_val
    FROM se_tr
    GROUP BY
        se_tr.trade_dt
        , se_tr.security_symbol_code
)

SELECT
    CAST(date_format(agg.trade_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(agg.security_symbol_code AS string)               AS security_symbol_code,
    CAST(agg.domestic_institution_buy_val AS decimal(23,2))        AS domestic_institution_buy_val,
    CAST(agg.domestic_institution_sell_val AS decimal(23,2))       AS domestic_institution_sell_val,
    CAST(agg.domestic_institution_buy_val - agg.domestic_institution_sell_val AS decimal(23,2)) AS domestic_institution_net_val
FROM agg
