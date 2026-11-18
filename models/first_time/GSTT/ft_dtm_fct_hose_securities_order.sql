-- [FIRST-TIME] ft_dtm_fct_hose_securities_order: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_hose_securities_order (config ft_target='fct_hose_securities_order', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_hose_securities_order
* Program name: Dtm Fct HOSE Securities Order
* Created by: tuan.nguyenvanb
* Created date: 2026-10-01
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-01		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_fct_hose_securities_order.csv]
*                                       Fact lenh dat HOSE - 1 dong / lenh dat (grain atomic
*                                       atm_securities_order, loc src_stm_code = 'ORDERTRADE_ORDER_BOOK_HOSE').
*                                       Toan bo cot direct tu atomic (khong lookup dim ngoai
*                                       cdr_dt_dim). trade_dt_dim_id format truc tiep tu
*                                       trade_dt (khong join dtm_cdr_dt_dim), dung quy uoc
*                                       chung GSTT. CANH BAO KHOI LUONG: bang rat lon, ClickHouse
*                                       flat nen luon loc theo cdr_dt + security_symbol_code
*                                       khi khai thac.
*--------------------------------------------------------------------*
*/

-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS-GSTT] TAM THOI chay MOT LUOT nhieu ngay (1 nam) cho UAT: bo loc etl_date, tra cuu theo tung ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
WITH se_or AS (
    SELECT
        trade_dt
        , market_id_code
        , security_symbol_code
        , currency_code
        , board_tp_code
        , order_dt
        , order_time
        , session_code
        , order_action_tp_code
        , order_accept_id
        , original_order_accept_id
        , side_ind
        , broker_id
        , broker_nm
        , account_pin_code
        , account_nbr
        , account_holder_nm
        , market_maker_order_ind
        , client_house_cl_code
        , investor_tp_code
        , foreign_investor_tp_code
        , order_tp_code
        , order_price
        , order_vol
        , order_condition_code
        , last_traded_price
        , execution_price
        , immediate_matched_vol
        , matched_vol
        , remaining_quantity
        , order_spread
        , matched_ratio
        , price_change_amt
        , price_change_tick
        , new_high_low_price_ind
        , order_status_code
        , icd_bug_quantity
        , expected_execution_price
        , expected_execution_vol
        , short_sell_tp_code
        , trader_nbr
        , trader_nm
        , reference_sequence_nbr
        , securities_order_code
        , original_order_code
    FROM {{ ft_ref('ft_atm_securities_order') }}
    -- [BACKFILL-UAT-ORIG] WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND src_stm_code = 'ORDERTRADE_ORDER_BOOK_HOSE'
    WHERE src_stm_code = 'ORDERTRADE_ORDER_BOOK_HOSE'   -- [BACKFILL-UAT-NEW]
)

SELECT
    CAST(date_format(se_or.trade_dt, 'yyyyMMdd') AS string)              AS trade_dt_dim_id,
    CAST(se_or.market_id_code AS string)                                 AS market_id_code,
    CAST(se_or.security_symbol_code AS string)                           AS security_symbol_code,
    CAST(se_or.currency_code AS string)                                  AS currency_code,
    CAST(se_or.board_tp_code AS string)                                  AS board_tp_code,
    CAST(se_or.order_dt AS date)                                         AS order_dt,
    CAST(se_or.order_time AS string)                                     AS order_time,
    CAST(se_or.session_code AS string)                                   AS session_code,
    CAST(se_or.order_action_tp_code AS string)                           AS order_action_tp_code,
    CAST(se_or.order_accept_id AS string)                                AS order_accept_id,
    CAST(se_or.original_order_accept_id AS string)                       AS original_order_accept_id,
    CAST(se_or.side_ind AS string)                                       AS side_ind,
    CAST(se_or.broker_id AS string)                                      AS broker_id,
    CAST(se_or.broker_nm AS string)                                      AS broker_nm,
    CAST(se_or.account_pin_code AS string)                               AS account_pin_code,
    CAST(se_or.account_nbr AS string)                                    AS account_nbr,
    CAST(se_or.account_holder_nm AS string)                              AS account_holder_nm,
    CAST(se_or.market_maker_order_ind AS string)                         AS market_maker_order_ind,
    CAST(se_or.client_house_cl_code AS string)                           AS client_house_cl_code,
    CAST(se_or.investor_tp_code AS string)                               AS investor_tp_code,
    CAST(se_or.foreign_investor_tp_code AS string)                       AS foreign_investor_tp_code,
    CAST(se_or.order_tp_code AS string)                                  AS order_tp_code,
    CAST(se_or.order_price AS decimal(23,2))                             AS order_price,
    CAST(se_or.order_vol AS int)                                         AS order_vol,
    CAST(se_or.order_condition_code AS string)                           AS order_condition_code,
    CAST(se_or.last_traded_price AS decimal(23,2))                       AS last_traded_price,
    CAST(se_or.execution_price AS decimal(23,2))                         AS execution_price,
    CAST(se_or.immediate_matched_vol AS int)                             AS immediate_matched_vol,
    CAST(se_or.matched_vol AS int)                                       AS matched_vol,
    CAST(se_or.remaining_quantity AS int)                                AS remaining_quantity,
    CAST(se_or.order_spread AS decimal(23,2))                            AS order_spread,
    CAST(se_or.matched_ratio AS decimal(5,2))                            AS matched_ratio,
    CAST(se_or.price_change_amt AS decimal(23,2))                        AS price_change_amt,
    CAST(se_or.price_change_tick AS int)                                 AS price_change_tick,
    CAST(se_or.new_high_low_price_ind AS string)                         AS new_high_low_price_ind,
    CAST(se_or.order_status_code AS string)                              AS order_status_code,
    CAST(se_or.icd_bug_quantity AS int)                                  AS icd_bug_quantity,
    CAST(se_or.expected_execution_price AS decimal(23,2))                AS expected_execution_price,
    CAST(se_or.expected_execution_vol AS int)                            AS expected_execution_vol,
    CAST(se_or.short_sell_tp_code AS string)                             AS short_sell_tp_code,
    CAST(se_or.trader_nbr AS string)                                     AS trader_nbr,
    CAST(se_or.trader_nm AS string)                                      AS trader_nm,
    CAST(se_or.reference_sequence_nbr AS string)                         AS reference_sequence_nbr,
    CAST(se_or.securities_order_code AS string)                          AS securities_order_code,
    CAST(se_or.original_order_code AS string)                            AS original_order_code
FROM se_or
