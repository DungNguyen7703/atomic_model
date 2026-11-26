/*
*--------------------------------------------------------------------*
* Program code: vp_fct_listed_corporate_bond_snpst_flat
* Program name: VP Fct Listed Corporate Bond Snapshot Flat
* Created by: huy.pham
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-18      claude          [O_VP_81, O_VP_87] Them listed_bond_val, remaining_term_days,
*                                 va 13 cot NDTNN/tu doanh/khop lenh/thoa thuan/YTM/floor/ticker.
* 2026-10-30      huy.pham        [MOI] Flat table ClickHouse: Fact Listed Corporate
*                                 Bond Snapshot x Calendar Date Dim x Industry Dim.
*                                 Grain = 1 ma ISIN / ngay GD.
*--------------------------------------------------------------------*
*/

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_LISTED_CORPORATE_BOND_SNPST
    CAST(f.listed_corporate_bond_snpst_id  AS string)           AS listed_corporate_bond_snpst_id,
    CAST(f.snpst_dt_dim_id                 AS string)           AS snpst_dt_dim_id,
    CAST(f.industry_dim_id                 AS string)           AS industry_dim_id,
    CAST(f.security_symbol_code            AS string)           AS security_symbol_code,
    CAST(f.listed_indicator                AS boolean)          AS listed_indicator,
    CAST(f.issue_term_years                AS decimal(23,2))    AS issue_term_years,
    CAST(f.remaining_term_years            AS decimal(23,6))    AS remaining_term_years,
    CAST(f.trading_vol                     AS bigint)           AS trading_vol,
    CAST(f.trading_val                     AS decimal(23,2))    AS trading_val,
    CAST(f.foreign_buy_val                 AS decimal(23,2))    AS foreign_buy_val,
    CAST(f.foreign_sell_val                AS decimal(23,2))    AS foreign_sell_val,
    CAST(f.outstanding_bond_quantity       AS bigint)           AS outstanding_bond_quantity,
    CAST(f.bond_outstanding_val            AS decimal(23,2))    AS bond_outstanding_val,
    CAST(f.listed_bond_val                 AS decimal(23,2))    AS listed_bond_val,
    CAST(f.remaining_term_days             AS int)              AS remaining_term_days,
    CAST(f.foreign_buy_vol                 AS bigint)           AS foreign_buy_vol,
    CAST(f.proprietary_buy_vol             AS bigint)           AS proprietary_buy_vol,
    CAST(f.proprietary_buy_val             AS decimal(23,2))    AS proprietary_buy_val,
    CAST(f.foreign_sell_vol                AS bigint)           AS foreign_sell_vol,
    CAST(f.proprietary_sell_vol            AS bigint)           AS proprietary_sell_vol,
    CAST(f.proprietary_sell_val            AS decimal(23,2))    AS proprietary_sell_val,
    CAST(f.order_matching_vol              AS bigint)           AS order_matching_vol,
    CAST(f.order_matching_val              AS decimal(23,2))    AS order_matching_val,
    CAST(f.negotiated_trade_vol            AS bigint)           AS negotiated_trade_vol,
    CAST(f.negotiated_trade_val            AS decimal(23,2))    AS negotiated_trade_val,
    CAST(f.yield_to_maturity_rate          AS decimal(8,5))     AS yield_to_maturity_rate,
    CAST(f.floor_code                      AS string)           AS floor_code,
    CAST(f.ticker_symbol                   AS string)           AS ticker_symbol,

    -- From: CALENDAR DATE DIMENSION
    CAST(to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS date)       AS cdr_dt,
    CAST(cal.year                          AS bigint)           AS year,
    CAST(cal.quarter                       AS bigint)           AS quarter,
    CAST(cal.month                         AS bigint)           AS month,
    CAST(cal.day_of_week                   AS bigint)           AS day_of_week,
    CAST(cal.is_weekend                    AS string)           AS is_weekend,
    CAST(cal.holiday_flag                  AS string)           AS holiday_flag,
    CAST(cal.is_trading_date               AS string)           AS is_trading_date,

    -- From: INDUSTRY DIMENSION
    CAST(ind.industry_code                 AS string)           AS industry_code,
    CAST(ind.industry_nm                   AS string)           AS industry_nm

FROM {{ ref('dtm_fct_listed_corporate_bond_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_industry_dim') }}_hstr ind
    ON  ind.industry_dim_id = f.industry_dim_id
    AND ind.ds_snpst_dt     = to_date('2026-11-05', 'yyyy-MM-dd')
    AND ind.ds_rcrd_st      = 'ACTIVE'
--WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')
