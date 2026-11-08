/*
*--------------------------------------------------------------------*
* Program code: dtm_securities_dim
* Program name: Dtm Securities Dim
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-17		nghia.le			[FIX] listed_share_count, total_listing_vol: CAST int -> bigint khop LLD
*									(data_type=bigint), tranh rui ro tran so voi ma von hoa lon.
*
*--------------------------------------------------------------------*
*/

WITH se_tr_sn_all AS (
    SELECT
        ticker_symbol,
        isin_code,
        full_nm,
        stock_tp_code,
        floor_code,
        listed_share_count,
        total_listing_vol,
        underlying_symbol,
        issuer_nm,
        listing_dt,
        symbol_status_code,
        trading_time,
        src_stm_code,
        ds_snpst_dt,
        sequence,
        row_number() over (partition by ticker_symbol order by trading_time DESC, sequence DESC) as rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
),

se_tr_sn AS (
    SELECT
        ticker_symbol,
        isin_code,
        full_nm,
        stock_tp_code,
        floor_code,
        listed_share_count,
        total_listing_vol,
        underlying_symbol,
        issuer_nm,
        listing_dt,
        symbol_status_code,
        trading_time,
        src_stm_code
    FROM se_tr_sn_all
    WHERE rn = 1
)

SELECT
    CAST({{ generate_surrogate_key_bigint('MDDS_JAD_STOCKINFOR', 'ticker_symbol') }} AS string) AS securities_dim_id,
    CAST(ticker_symbol AS string)                                                        AS symbol,
    CAST(isin_code AS string)                                                            AS isin_code,
    CAST(full_nm AS string)                                                              AS security_full_nm,
    CAST(stock_tp_code AS string)                                                        AS stock_tp_code,
    CAST(floor_code AS string)                                                           AS floor_code,
    CAST(listed_share_count AS bigint)                                                   AS listed_share_count,
    CAST(total_listing_vol AS bigint)                                                    AS total_listing_vol,
    CAST(underlying_symbol AS string)                                                    AS underlying_symbol,
    CAST(issuer_nm AS string)                                                            AS issuer_nm,
    CAST(listing_dt AS date)                                                             AS listing_dt,
    CAST(symbol_status_code AS string)                                                   AS symbol_status_code,
    CAST(trading_time AS string)                                                         AS trading_time,
    CAST(src_stm_code AS string)                                                         AS src_stm_code
FROM se_tr_sn
