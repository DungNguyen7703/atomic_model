-- [FIRST-TIME] ft_atm_securities_order_ordertrade_order_book_hnx: ban ephemeral cua atm_securities_order_ordertrade_order_book_hnx cho bo first-time.
/*
*--------------------------------------------------------------------*
* Program code: atm_securities_order
* Program name: Atomic Securities Order ORDERTRADE.ORDER_BOOK_HNX
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Schema chuan hoa theo LLD_ORDERTRADE_ORDER_BOOK_HNX.yaml + LLD_ORDERTRADE_ORDER_BOOK_HOSE.yaml
* (2 nguon HNX/HOSE union vao chung 1 Atomic Entity "Securities Order" - phai cung
* 1 bo cot/thu tu/kieu du lieu de UNION ALL voi atm_securities_order_ordertrade_order_book_hose).
* Field nao HNX khong co (theo LLD) -> NULL.
*--------------------------------------------------------------------*
*/

-- 2026-10-09 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
WITH or_bo_hn AS (
    SELECT
        order_id
        , trade_date
        , market_id
        , board_id
        , issue_code
        , member_id
        , sell_buy_classification_code
        , account_number
        , order_type_code
        , order_condition_code
        , client_house_classification_code
        , investor_classification_code
        , order_date
        , order_quantity
        , order_price
        , session_id
        , order_remaining_quantity
        , replace_cancel
        , original_order_id
        , foreign_investor_type_code
        , order_accept_time
        , order_reject_reason_code
        , public_quantity
        , condition_price
        , order_reception_number
        , original_order_reception_number
        , original_order_type_code
        , message_sequence
        , quote_request_type
        , automated_cancel
    FROM {{ ft_ref('ft_ods_hnx_order_book') }}
    -- [BACKFILL-UAT-ORIG] WHERE TRADE_DATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
-- [BACKFILL-UAT-ORIG] or TRADE_DATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyyMMdd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyyMMdd')
)

SELECT
    {{ generate_surrogate_key_bigint('ORDERTRADE_ORDER_BOOK_HNX', "or_bo_hn.order_id") }} AS securities_order_id
    , CAST(or_bo_hn.order_id AS string)                                                   AS securities_order_code
    , CAST('ORDERTRADE_ORDER_BOOK_HNX' AS string)                                         AS src_stm_code
    , CAST(or_bo_hn.trade_date AS date)                                                   AS trade_dt
    , CAST(or_bo_hn.market_id AS string)                                                  AS market_id_code
    , CAST(or_bo_hn.board_id AS string)                                                   AS board_tp_code
    , CAST(or_bo_hn.issue_code AS string)                                                 AS security_symbol_code
    , CAST(or_bo_hn.member_id AS string)                                                  AS broker_id
    , CAST(or_bo_hn.sell_buy_classification_code AS string)                               AS side_ind
    , CAST(or_bo_hn.account_number AS string)                                             AS account_nbr
    , CAST(or_bo_hn.order_type_code AS string)                                            AS order_tp_code
    , CAST(or_bo_hn.order_condition_code AS string)                                       AS order_condition_code
    , CAST(or_bo_hn.client_house_classification_code AS string)                           AS client_house_cl_code
    , CAST(or_bo_hn.investor_classification_code AS string)                               AS investor_tp_code
    , CAST(or_bo_hn.order_date AS date)                                                   AS order_dt
    , CAST(or_bo_hn.order_quantity AS int)                                                AS order_vol
    , CAST(or_bo_hn.order_price AS decimal(23,2))                                         AS order_price
    , CAST(or_bo_hn.session_id AS string)                                                 AS session_code
    , CAST(or_bo_hn.order_remaining_quantity AS int)                                      AS remaining_quantity
    , CAST(or_bo_hn.replace_cancel AS string)                                             AS order_action_tp_code
    , CAST(or_bo_hn.original_order_id AS string)                                          AS original_order_code
    , CAST(or_bo_hn.foreign_investor_type_code AS string)                                 AS foreign_investor_tp_code
    , CAST(null AS string)                                                                AS order_status_code
    -- HNX-only (khong co ben HOSE theo LLD)
    , CAST(or_bo_hn.order_accept_time AS string)                                          AS order_accept_time
    , CAST(or_bo_hn.order_reject_reason_code AS string)                                   AS order_reject_reason_code
    , CAST(or_bo_hn.public_quantity AS int)                                               AS public_vol
    , CAST(or_bo_hn.condition_price AS decimal(23,2))                                     AS condition_price
    , CAST(or_bo_hn.order_reception_number AS string)                                     AS order_reception_nbr
    , CAST(or_bo_hn.original_order_reception_number AS string)                            AS original_order_reception_nbr
    , CAST(or_bo_hn.original_order_type_code AS string)                                   AS original_order_tp_code
    , CAST(or_bo_hn.message_sequence AS int)                                              AS message_sequence_nbr
    , CAST(or_bo_hn.quote_request_type AS string)                                         AS quote_request_tp_code
    , CAST(or_bo_hn.automated_cancel AS string)                                           AS auto_cancel_reason_code
    -- HOSE-only (khong co ben HNX theo LLD) - NULL het
    , CAST(null AS string)                                                                AS currency_code
    , CAST(null AS string)                                                                AS order_time
    , CAST(null AS string)                                                                AS order_accept_id
    , CAST(null AS string)                                                                AS original_order_accept_id
    , CAST(null AS string)                                                                AS broker_nm
    , CAST(null AS string)                                                                AS account_pin_code
    , CAST(null AS string)                                                                AS account_holder_nm
    , CAST(null AS string)                                                                AS market_maker_order_ind
    , CAST(null AS decimal(23,2))                                                         AS last_traded_price
    , CAST(null AS decimal(23,2))                                                         AS execution_price
    , CAST(null AS int)                                                                   AS immediate_matched_vol
    , CAST(null AS int)                                                                   AS matched_vol
    , CAST(null AS decimal(23,2))                                                         AS order_spread
    , CAST(null AS decimal(5,2))                                                          AS matched_ratio
    , CAST(null AS decimal(23,2))                                                         AS price_change_amt
    , CAST(null AS int)                                                                   AS price_change_tick
    , CAST(null AS string)                                                                AS new_high_low_price_ind
    , CAST(null AS int)                                                                   AS icd_bug_quantity
    , CAST(null AS decimal(23,2))                                                         AS expected_execution_price
    , CAST(null AS int)                                                                   AS expected_execution_vol
    , CAST(null AS string)                                                                AS short_sell_tp_code
    , CAST(null AS string)                                                                AS trader_nbr
    , CAST(null AS string)                                                                AS trader_nm
    , CAST(null AS string)                                                                AS reference_sequence_nbr
FROM or_bo_hn
