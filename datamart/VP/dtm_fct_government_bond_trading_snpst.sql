/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_government_bond_trading_snpst
* Program name: Dtm Fct Government Bond Trading Snapshot
* Created by: huy.pham
* Created date: 2026-10-29
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-10-29      huy.pham        [MOI, theo LLD DTM_VP_fct_government_bond_trading_
*                                 snpst.csv] Fact snapshot GD TP Chinh phu theo ngay
*                                 GD va loai so lenh. Grain = 1 dong / ngay GD /
*                                 order_book_type / src_stm_code (OUTRIGHT | REPO).
*                                 Nguon atm_bond_order_book, src_stm_code IN (HNX_
*                                 OUTRIGHT_ORDER_BOOK, HNX_REPO_ORDER_BOOK) — loai
*                                 REPO2. Chi lay order_status='DTH' (O_VP_31). Gia tri
*                                 GD: OUTRIGHT dung trading_value, REPO dung
*                                 first_settlement_value (O_VP_32). foreign_buy/sell:
*                                 SUBSTR(account_no,4,1) IN ('E','F'). src_stm_code
*                                 tham gia khoa PK de tranh trung khi nhieu nguon.
*--------------------------------------------------------------------*
*/

WITH ob AS (
    SELECT
        src_stm_code,
        trading_date,
        order_book_type,
        order_bond_quantity,
        CASE
            WHEN order_book_type = 'OUTRIGHT' THEN trading_value
            WHEN order_book_type = 'REPO'     THEN first_settlement_value
        END AS trade_val,
        buying_account_no,
        selling_account_no
    FROM {{ ref('atm_bond_order_book') }}
    WHERE src_stm_code      IN ('HNX_OUTRIGHT_ORDER_BOOK', 'HNX_REPO_ORDER_BOOK')
        AND order_book_type IN ('OUTRIGHT', 'REPO')
        AND order_status     = 'ĐTH'
        AND trading_date     = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

agg AS (
    SELECT
        src_stm_code,
        trading_date,
        order_book_type,
        SUM(order_bond_quantity)                                                               AS trading_vol,
        SUM(trade_val)                                                                         AS trading_val,
        SUM(CASE WHEN SUBSTR(buying_account_no, 4, 1)  IN ('E', 'F') THEN trade_val END)     AS foreign_buy_val,
        SUM(CASE WHEN SUBSTR(selling_account_no, 4, 1) IN ('E', 'F') THEN trade_val END)     AS foreign_sell_val
    FROM ob
    GROUP BY src_stm_code, trading_date, order_book_type
)

SELECT
    CAST({{ generate_surrogate_key_bigint('HNX_BOND_ORDER_BOOK', "CONCAT(date_format(trading_date,'yyyyMMdd'), '|', order_book_type, '|', src_stm_code)") }} AS string) AS government_bond_trading_snpst_id,
    CAST(date_format(trading_date, 'yyyyMMdd') AS string)  AS snpst_dt_dim_id,
    CAST(order_book_type AS string)                        AS order_book_tp,
    CAST(trading_vol AS bigint)                            AS trading_vol,
    CAST(trading_val AS decimal(23,2))                     AS trading_val,
    CAST(foreign_buy_val AS decimal(23,2))                 AS foreign_buy_val,
    CAST(foreign_sell_val AS decimal(23,2))                AS foreign_sell_val,
    CAST(src_stm_code AS string)                           AS src_stm_code
FROM agg
