/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_hnx_securities_order
* Program name: Dtm Fct HNX Securities Order
* Created by: tuan.nguyenvanb
* Created date: 2026-10-01
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-01		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_fct_hnx_securities_order.csv]
*                                       Fact lenh dat HNX - 1 dong / lenh dat (grain atomic
*                                       atm_securities_order, loc src_stm_code = 'ORDERTRADE_ORDER_BOOK_HNX').
*                                       Toan bo cot direct tu atomic (khong lookup dim ngoai
*                                       cdr_dt_dim). trade_dt_dim_id format truc tiep tu
*                                       trade_dt (khong join dtm_cdr_dt_dim), dung quy uoc
*                                       chung GSTT. CANH BAO KHOI LUONG: bang rat lon, ClickHouse
*                                       flat nen luon loc theo cdr_dt + security_symbol_code
*                                       khi khai thac.
*--------------------------------------------------------------------*
*/

WITH se_or AS (
    SELECT
        trade_dt
        , market_id_code
        , board_tp_code
        , security_symbol_code
        , order_accept_time
        , broker_id
        , side_ind
        , account_nbr
        , order_tp_code
        , order_condition_code
        , client_house_cl_code
        , investor_tp_code
        , order_dt
        , order_reject_reason_code
        , order_vol
        , order_price
        , public_vol
        , condition_price
        , order_reception_nbr
        , original_order_reception_nbr
        , original_order_tp_code
        , session_code
        , remaining_quantity
        , message_sequence_nbr
        , order_action_tp_code
        , quote_request_tp_code
        , auto_cancel_reason_code
        , securities_order_code
        , original_order_code
        , foreign_investor_tp_code
    FROM {{ ref('atm_securities_order') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'ORDERTRADE_ORDER_BOOK_HNX'
)

SELECT
    CAST(date_format(se_or.trade_dt, 'yyyyMMdd') AS string)              AS trade_dt_dim_id,
    CAST(se_or.market_id_code AS string)                                 AS market_id_code,
    CAST(se_or.board_tp_code AS string)                                  AS board_tp_code,
    CAST(se_or.security_symbol_code AS string)                           AS security_symbol_code,
    CAST(se_or.order_accept_time AS string)                              AS order_accept_time,
    CAST(se_or.broker_id AS string)                                      AS broker_id,
    CAST(se_or.side_ind AS string)                                       AS side_ind,
    CAST(se_or.account_nbr AS string)                                    AS account_nbr,
    CAST(se_or.order_tp_code AS string)                                  AS order_tp_code,
    CAST(se_or.order_condition_code AS string)                           AS order_condition_code,
    CAST(se_or.client_house_cl_code AS string)                           AS client_house_cl_code,
    CAST(se_or.investor_tp_code AS string)                               AS investor_tp_code,
    CAST(se_or.order_dt AS date)                                         AS order_dt,
    CAST(se_or.order_reject_reason_code AS string)                       AS order_reject_reason_code,
    CAST(se_or.order_vol AS int)                                         AS order_vol,
    CAST(se_or.order_price AS decimal(23,2))                             AS order_price,
    CAST(se_or.public_vol AS int)                                        AS public_vol,
    CAST(se_or.condition_price AS decimal(23,2))                         AS condition_price,
    CAST(se_or.order_reception_nbr AS string)                            AS order_reception_nbr,
    CAST(se_or.original_order_reception_nbr AS string)                   AS original_order_reception_nbr,
    CAST(se_or.original_order_tp_code AS string)                         AS original_order_tp_code,
    CAST(se_or.session_code AS string)                                   AS session_code,
    CAST(se_or.remaining_quantity AS int)                                AS remaining_quantity,
    CAST(se_or.message_sequence_nbr AS int)                              AS message_sequence_nbr,
    CAST(se_or.order_action_tp_code AS string)                           AS order_action_tp_code,
    CAST(se_or.quote_request_tp_code AS string)                          AS quote_request_tp_code,
    CAST(se_or.auto_cancel_reason_code AS string)                        AS auto_cancel_reason_code,
    CAST(se_or.securities_order_code AS string)                          AS securities_order_code,
    CAST(se_or.original_order_code AS string)                            AS original_order_code,
    CAST(se_or.foreign_investor_tp_code AS string)                       AS foreign_investor_tp_code
FROM se_or
