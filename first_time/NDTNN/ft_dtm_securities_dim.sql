-- [FIRST-TIME] ft_dtm_securities_dim: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_securities_dim (config ft_target='securities_dim', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_securities_dim
* Program name: Dtm Securities Dim
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		nghia.le			[FIRST-TIME NDTNN] ft_hstr_by_day: snapshot TUNG NGAY tu lich su atomic (ft_atm_security_trading_snapshot), 1 ban ghi/ma/ngay,
*									them cot ds_snpst_dt cuoi. Cac model first-time NDTNN doc _hstr theo NGAY (khong doc MAIN) de khop daily.
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
        sequence,   -- [FT-NEW] ngay snapshot
        row_number() over (partition by ticker_symbol, ds_snpst_dt order by trading_time DESC, sequence DESC) as rn   -- [FT-NEW] 1 ban ghi / ma / ngay
    -- [FT-ORIG] FROM {{ ref('atm_security_trading_snapshot') }}
    -- [FT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [FT-NEW] lich su snapshot TUNG NGAY (bo first-time GSTT)
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'   -- [FT-NEW] bo loc ds_snpst_dt = etl_date
        AND ds_snpst_dt IS NOT NULL
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
        src_stm_code,
        ds_snpst_dt
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
    CAST(src_stm_code AS string)                                                         AS src_stm_code,
    CAST(ds_snpst_dt AS date)                                                            AS ds_snpst_dt   -- [FIRST-TIME 2026-10-18] ngay snapshot (ft_hstr_by_day)
FROM se_tr_sn
