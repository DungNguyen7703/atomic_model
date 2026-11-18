-- [FIRST-TIME] ft_atm_securities_order_ordertrade_order_book_hose: ban ephemeral cua atm_securities_order_ordertrade_order_book_hose cho bo first-time.
/*
*--------------------------------------------------------------------*
* Program code: atm_securities_order
* Program name: Atomic Securities Order ORDERTRADE.ORDER_BOOK_HOSE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Schema chuan hoa theo LLD_ORDERTRADE_ORDER_BOOK_HNX.yaml + LLD_ORDERTRADE_ORDER_BOOK_HOSE.yaml
* (2 nguon HNX/HOSE union vao chung 1 Atomic Entity "Securities Order" - phai cung
* 1 bo cot/thu tu/kieu du lieu de UNION ALL voi atm_securities_order_ordertrade_order_book_hnx).
* Field nao HOSE khong co (theo LLD) -> NULL.
*--------------------------------------------------------------------*
*/

-- 2026-10-09 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
WITH or_bo_ho AS (
    SELECT
        order_id
        , trade_date
        , market_id
        , symbol
        , currency
        , board_type
        , order_date
        , order_time
        , session
        , modify_cancel
        , order_accept_id
        , orig_order_accept_id
        , orig_order_id
        , side
        , brk_id
        , brk
        , pin
        , acct_no
        , name
        , market_maker_order
        , client_house_classification_code
        , invest_type
        , foreigner_investor_type
        , order_type
        , order_price
        , order_vol
        , order_condition
        , ltp
        , execution_price
        , immed_matched_vol
        , matched_vol
        , order_rqty
        , order_price_ltp
        , matched_ratio
        , buy_up_sell_down_amt
        , buy_up_sell_down_tick
        , new_high_low_price
        , order_status
        , icd_bug_qty
        , expected_execution_price
        , expected_execution_volume
        , short_sell_indicator
        , trader_no
        , trader_name
        , reference_sequence_no
    FROM {{ ft_ref('ft_ods_hose_order_book') }}
    -- [BACKFILL-UAT-ORIG] WHERE TRADE_DATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
-- [BACKFILL-UAT-ORIG] or TRADE_DATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyyMMdd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyyMMdd')
)

SELECT
    {{ generate_surrogate_key_bigint('ORDERTRADE_ORDER_BOOK_HOSE', "or_bo_ho.order_id") }} AS securities_order_id
    , CAST(or_bo_ho.order_id AS string)                                                    AS securities_order_code
    , CAST('ORDERTRADE_ORDER_BOOK_HOSE' AS string)                                         AS src_stm_code
    , CAST(or_bo_ho.trade_date AS date)                                                    AS trade_dt
    , CAST(or_bo_ho.market_id AS string)                                                   AS market_id_code
    , CAST(or_bo_ho.board_type AS string)                                                  AS board_tp_code
    , CAST(or_bo_ho.symbol AS string)                                                      AS security_symbol_code
    , CAST(or_bo_ho.brk_id AS string)                                                      AS broker_id
    , CAST(or_bo_ho.side AS string)                                                        AS side_ind
    , CAST(or_bo_ho.acct_no AS string)                                                     AS account_nbr
    , CAST(or_bo_ho.order_type AS string)                                                  AS order_tp_code
    , CAST(or_bo_ho.order_condition AS string)                                             AS order_condition_code
    , CAST(or_bo_ho.client_house_classification_code AS string)                            AS client_house_cl_code
    , CAST(or_bo_ho.invest_type AS string)                                                 AS investor_tp_code
    , CAST(or_bo_ho.order_date AS date)                                                    AS order_dt
    , CAST(or_bo_ho.order_vol AS int)                                                      AS order_vol
    , CAST(or_bo_ho.order_price AS decimal(23,2))                                          AS order_price
    , CAST(or_bo_ho.session AS string)                                                     AS session_code
    , CAST(or_bo_ho.order_rqty AS int)                                                     AS remaining_quantity
    , CAST(or_bo_ho.modify_cancel AS string)                                               AS order_action_tp_code
    , CAST(or_bo_ho.orig_order_id AS string)                                               AS original_order_code
    , CAST(or_bo_ho.foreigner_investor_type AS string)                                     AS foreign_investor_tp_code
    , CAST(or_bo_ho.order_status AS string)                                                AS order_status_code
    -- HNX-only (khong co ben HOSE theo LLD) - NULL het
    , CAST(null AS string)                                                                 AS order_accept_time
    , CAST(null AS string)                                                                 AS order_reject_reason_code
    , CAST(null AS int)                                                                    AS public_vol
    , CAST(null AS decimal(23,2))                                                          AS condition_price
    , CAST(null AS string)                                                                 AS order_reception_nbr
    , CAST(null AS string)                                                                 AS original_order_reception_nbr
    , CAST(null AS string)                                                                 AS original_order_tp_code
    , CAST(null AS int)                                                                    AS message_sequence_nbr
    , CAST(null AS string)                                                                 AS quote_request_tp_code
    , CAST(null AS string)                                                                 AS auto_cancel_reason_code
    -- HOSE-only (khong co ben HNX theo LLD)
    , CAST(or_bo_ho.currency AS string)                                                    AS currency_code
    , CAST(or_bo_ho.order_time AS string)                                                  AS order_time
    , CAST(or_bo_ho.order_accept_id AS string)                                             AS order_accept_id
    , CAST(or_bo_ho.orig_order_accept_id AS string)                                        AS original_order_accept_id
    , CAST(or_bo_ho.brk AS string)                                                         AS broker_nm
    , CAST(or_bo_ho.pin AS string)                                                         AS account_pin_code
    , CAST(or_bo_ho.name AS string)                                                        AS account_holder_nm
    , CAST(or_bo_ho.market_maker_order AS string)                                          AS market_maker_order_ind
    , CAST(or_bo_ho.ltp AS decimal(23,2))                                                  AS last_traded_price
    , CAST(or_bo_ho.execution_price AS decimal(23,2))                                      AS execution_price
    , CAST(or_bo_ho.immed_matched_vol AS int)                                              AS immediate_matched_vol
    , CAST(or_bo_ho.matched_vol AS int)                                                    AS matched_vol
    , CAST(or_bo_ho.order_price_ltp AS decimal(23,2))                                      AS order_spread
    , CAST(or_bo_ho.matched_ratio AS decimal(5,2))                                         AS matched_ratio
    , CAST(or_bo_ho.buy_up_sell_down_amt AS decimal(23,2))                                 AS price_change_amt
    , CAST(or_bo_ho.buy_up_sell_down_tick AS int)                                          AS price_change_tick
    , CAST(or_bo_ho.new_high_low_price AS string)                                          AS new_high_low_price_ind
    , CAST(or_bo_ho.icd_bug_qty AS int)                                                    AS icd_bug_quantity
    , CAST(or_bo_ho.expected_execution_price AS decimal(23,2))                             AS expected_execution_price
    , CAST(or_bo_ho.expected_execution_volume AS int)                                      AS expected_execution_vol
    , CAST(or_bo_ho.short_sell_indicator AS string)                                        AS short_sell_tp_code
    , CAST(or_bo_ho.trader_no AS string)                                                   AS trader_nbr
    , CAST(or_bo_ho.trader_name AS string)                                                 AS trader_nm
    , CAST(or_bo_ho.reference_sequence_no AS string)                                       AS reference_sequence_nbr
FROM or_bo_ho
