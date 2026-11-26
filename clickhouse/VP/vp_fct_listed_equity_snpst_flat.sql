/*
*--------------------------------------------------------------------*
* Program code: vp_fct_listed_equity_snpst_flat
* Program name: VP Fct Listed Equity Snapshot Flat
* Created by: huy.pham
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-10-30      huy.pham        [MOI] Flat table ClickHouse: Fact Listed Equity
*                                 Snapshot x Calendar Date Dim.
*                                 Grain = 1 ma (stock_tp_code 2/3/6) / ngay GD.
*                                 next_day_vol_weighted_average_price/market_price/
*                                 market_cap_val = NULL cho dong ngay D (chua co D+1).
*                                 CAST tuong minh cho tung cot de khop kieu CK DDL.
* 2026-11-08      huy.pham        [SUA] Chuyen sang full load moi lan ETL: bo filter
*                                 snpst_dt_dim_id. SELECT toan bo tu dtm moi lan chay.
*                                 ck_snapshot inject ds_snpst_dt = etl_date cho tat ca
*                                 dong → ghi vao 1 partition moi moi run. Khai thac
*                                 WHERE ds_snpst_dt = max(ds_snpst_dt).
* 2026-11-09      huy.pham        [SUA, O_VP_66, O_VP_68] Them snpst_dt_dim_id,
*                                 fund_tp_code, industry_dim_id (tu fact). Them
*                                 industry_code, industry_nm: JOIN dtm_industry_dim.
*                                 Mo rong stock_tp_code 1/2/3/4/6 (TPDN NY, CW).
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_LISTED_EQUITY_SNPST
    CAST(f.listed_equity_snpst_id                   AS string)           AS listed_equity_snpst_id,
    CAST(f.snpst_dt_dim_id                          AS string)           AS snpst_dt_dim_id,
    CAST(f.industry_dim_id                          AS string)           AS industry_dim_id,
    CAST(f.ticker_symbol                            AS string)           AS ticker_symbol,
    CAST(f.floor_code                               AS string)           AS floor_code,
    CAST(f.stock_tp_code                            AS string)           AS stock_tp_code,
    CAST(f.fund_tp_code                             AS string)           AS fund_tp_code,
    CAST(f.outstanding_share_quantity               AS decimal(23,2))           AS outstanding_share_quantity,
    CAST(f.listed_share_quantity                    AS decimal(23,2))           AS listed_share_quantity,
    CAST(f.listed_share_val                         AS decimal(23,2))    AS listed_share_val,
    CAST(f.close_price                              AS decimal(23,2))    AS close_price,
    CAST(f.reference_price                          AS decimal(23,2))    AS reference_price,
    CAST(f.next_day_vol_weighted_average_price      AS decimal(23,2))           AS next_day_vol_weighted_average_price,
    CAST(f.market_price                             AS decimal(23,2))    AS market_price,
    CAST(f.market_cap_val                           AS decimal(23,2))    AS market_cap_val,
    CAST(f.src_stm_code                             AS string)           AS src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    CAST(to_date(f.snpst_dt_dim_id, 'yyyyMMdd')     AS date)             AS cdr_dt,
    CAST(cal.year                                   AS bigint)           AS year,
    CAST(cal.quarter                                AS bigint)           AS quarter,
    CAST(cal.month                                  AS bigint)           AS month,
    CAST(cal.day_of_week                            AS bigint)           AS day_of_week,
    CAST(cal.is_weekend                             AS string)           AS is_weekend,
    CAST(cal.holiday_flag                           AS string)           AS holiday_flag,
    CAST(cal.is_trading_date                        AS string)           AS is_trading_date,

    -- From: INDUSTRY DIMENSION
    CAST(ind.industry_code                          AS string)           AS industry_code,
    CAST(ind.industry_nm                            AS string)           AS industry_nm

FROM {{ ref('dtm_fct_listed_equity_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_industry_dim') }}_hstr ind
    ON  ind.industry_dim_id = f.industry_dim_id
    and ind.ds_snpst_dt = to_date('2026-11-05','yyyy-MM-dd') --to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
