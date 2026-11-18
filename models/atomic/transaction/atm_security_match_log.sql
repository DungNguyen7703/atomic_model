/*
*--------------------------------------------------------------------*
* Program code: atm_security_match_log
* Program name: Atomic Security Match Log
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-22		tuan.nguyenvanb		[DONG BO DESIGN 2026-10-21] symbol->ticker_symbol; match_vol/accumulated_vol/total_buy_vol/total_sell_vol int->bigint;
*									them price_change (FORMATTEDCHANGEVALUE, decimal(23,2)) o CUOI SELECT. Bang vat ly: RENAME/ALTER TYPE + ADD COLUMN
*									... AFTER board_id (xem scratch/alter_atomic_rename_20261022.sql) TRUOC khi chay.
*--------------------------------------------------------------------*
*/

WITH ja_tr AS (
    SELECT
        kid
        , symbol
        , tradingdate
        , formattedtime
        , sequencemsg
        , lastcolor
        , changecolor
        , formattedmatchprice
        , formattedvol
        , formattedaccvol
        , formattedaccval
        , totalbuyvol
        , totalsellvol
        , boardid
        , formattedchangevalue
    FROM {{ ref('ods_mdds_jad_translog') }}
    WHERE TRADINGDATE = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('MDDS_JAD_TRANSLOG', "ja_tr.kid") }} AS security_match_log_id
    , CAST(ja_tr.kid AS string)                                          AS security_match_log_code
    , CAST('MDDS_JAD_TRANSLOG' AS string)                                AS src_stm_code
    , CAST(ja_tr.symbol AS string)                                       AS ticker_symbol
    , CAST(ja_tr.tradingdate AS date)                                    AS trading_dt
    , CAST(ja_tr.formattedtime AS string)                                AS match_time
    , CAST(ja_tr.sequencemsg AS string)                                  AS sequence_message
    , CAST(ja_tr.lastcolor AS string)                                    AS trade_direction_code
    , CAST(ja_tr.changecolor AS string)                                  AS change_color_code
    , CAST(ja_tr.formattedmatchprice AS decimal(23,2))                   AS match_price
    , CAST(ja_tr.formattedvol AS bigint)                                    AS match_vol
    , CAST(ja_tr.formattedaccvol AS bigint)                                 AS accumulated_vol
    , CAST(ja_tr.formattedaccval AS decimal(23,2))                       AS accumulated_val
    , CAST(ja_tr.totalbuyvol AS bigint)                                     AS total_buy_vol
    , CAST(ja_tr.totalsellvol AS bigint)                                    AS total_sell_vol
    , CAST(ja_tr.boardid AS string)                                      AS board_id
    , CAST(ja_tr.formattedchangevalue AS decimal(23,2))                  AS price_change
FROM ja_tr