-- [FIRST-TIME] ft_atm_security_match_log: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_security_match_log (config ft_target='security_match_log', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: atm_security_match_log
* Program name: Atomic Security Match Log
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-15		tuan.nguyenvanb		Tao moi theo atm_security_match_log daily (17 cot, partition trading_dt); doc ft_ods_mdds_jad_translog, bo loc data_dt.
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [FIRST-TIME 2026-11-15] append, partition trading_dt giong daily

WITH ja_tr AS (
    SELECT
        kid
        , boardid
        , changecolor
        , formattedaccval
        , formattedaccvol
        , formattedchangevalue
        , formattedmatchprice
        , formattedtime
        , formattedvol
        , lastcolor
        , sequencemsg
        , symbol
        , totalbuyvol
        , totalsellvol
        , tradingdate
    FROM {{ ft_ref('ft_ods_mdds_jad_translog') }}
    -- [BACKFILL-UAT-ORIG] daily loc WHERE data_dt = ngay chay; first-time lay toan bo lich su, khong loc
)

SELECT
    {{ generate_surrogate_key_bigint('MDDS_JAD_TRANSLOG', "ja_tr.kid") }}   AS security_match_log_id
    , CAST(ja_tr.kid AS string)                                               AS security_match_log_code
    , CAST('MDDS_JAD_TRANSLOG' AS string)                                     AS src_stm_code
    , CAST(ja_tr.boardid AS string)                                           AS board_id
    , CAST(ja_tr.changecolor AS string)                                       AS change_color_code
    , CAST(ja_tr.formattedaccval AS decimal(23,2))                            AS accumulated_val
    , CAST(ja_tr.formattedaccvol AS bigint)                                   AS accumulated_vol
    , CAST(ja_tr.formattedchangevalue AS decimal(23,2))                       AS price_change
    , CAST(ja_tr.formattedmatchprice AS decimal(23,2))                        AS match_price
    , CAST(ja_tr.formattedtime AS string)                                     AS match_time
    , CAST(ja_tr.formattedvol AS bigint)                                      AS match_vol
    , CAST(ja_tr.lastcolor AS string)                                         AS trade_direction_code
    , CAST(ja_tr.sequencemsg AS string)                                       AS sequence_message
    , CAST(ja_tr.symbol AS string)                                            AS ticker_symbol
    , CAST(ja_tr.totalbuyvol AS bigint)                                       AS total_buy_vol
    , CAST(ja_tr.totalsellvol AS bigint)                                      AS total_sell_vol
    , CAST(to_date(ja_tr.tradingdate, 'dd/MM/yyyy') AS date)                  AS trading_dt
FROM ja_tr
