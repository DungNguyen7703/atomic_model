/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_market_index_snpst
* Program name: Dtm Fct Market Index Snpst
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-07		tuan.nguyenvanb		Bo JOIN dtm_cdr_dt_dim - tu tinh snpst_dt_dim_id
*                                       truc tiep bang date_format(trading_dt,'yyyyMMdd'),
*                                       giong quy uoc cdr_dt_dim_id da dung o cac mart khac
*                                       (vd GSTT) - khong can bang calendar dim that.
*                                       Bo sung 12 cot open/high/low/prior_index,
*                                       index_change, index_percent_change, advances/
*                                       declines/no_change_count, ceiling/floor_count -
*                                       da co san trong atm_market_index_snapshot.
* 2026-09-24		tuan.nguyenvanb		Dong bo lai theo LLD/datamart_model.yaml da duyet -
*                                       bo 4 cot odd_lot_total_vol/val, pt_total_vol/val
*                                       (UNRESOLVED_COLUMN, khong co trong thiet ke chinh
*                                       thuc, chi qlkd_fct_market_index_snpst_flat ben
*                                       clickhouse/ dang doc).
*--------------------------------------------------------------------*
*/

WITH ma_in_sn_all AS (
    SELECT
        market_index_val,
        market_id,
        market_code,
        trading_dt,
        index_time,
        open_index,
        high_index,
        low_index,
        prior_index,
        index_change,
        index_percent_change,
        advances_count,
        declines_count,
        no_change_count,
        ceiling_count,
        floor_count,
        odd_lot_total_vol,
        odd_lot_total_val,
        pt_total_vol,
        pt_total_val,
        row_number() over (partition by market_id, market_code, trading_dt order by index_time desc) as rn
    FROM {{ ref('atm_market_index_snapshot') }}
    WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

ma_in_sn AS (
    SELECT
        market_index_val,
        market_id,
        market_code,
        trading_dt,
        open_index,
        high_index,
        low_index,
        prior_index,
        index_change,
        index_percent_change,
        advances_count,
        declines_count,
        no_change_count,
        ceiling_count,
        floor_count,
        odd_lot_total_vol,
        odd_lot_total_val,
        pt_total_vol,
        pt_total_val
    FROM ma_in_sn_all
    WHERE rn = 1
),

ma_in_di AS (
    SELECT market_index_dim_id, market_id, market_code
    FROM {{ ref('dtm_market_index_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    CAST(date_format(ma_in_sn.trading_dt, 'yyyyMMdd') AS string)             AS snpst_dt_dim_id,
    CAST(ma_in_di.market_index_dim_id AS string)                             AS market_index_dim_id,
    CAST(ma_in_sn.market_index_val AS decimal(23,2))                         AS market_index_val,
    CAST(ma_in_sn.open_index AS decimal(23,2))                               AS open_index,
    CAST(ma_in_sn.high_index AS decimal(23,2))                               AS high_index,
    CAST(ma_in_sn.low_index AS decimal(23,2))                                AS low_index,
    CAST(ma_in_sn.prior_index AS decimal(23,2))                              AS prior_index,
    CAST(ma_in_sn.index_change AS decimal(23,2))                             AS index_change,
    CAST(ma_in_sn.index_percent_change AS decimal(5,2))                      AS index_percent_change,
    CAST(ma_in_sn.advances_count AS int)                                     AS advances_count,
    CAST(ma_in_sn.declines_count AS int)                                     AS declines_count,
    CAST(ma_in_sn.no_change_count AS int)                                    AS no_change_count,
    CAST(ma_in_sn.ceiling_count AS int)                                      AS ceiling_count,
    CAST(ma_in_sn.floor_count AS int)                                        AS floor_count,
    CAST(ma_in_sn.odd_lot_total_vol AS int)                                  AS odd_lot_total_vol,
    CAST(ma_in_sn.odd_lot_total_val AS decimal(23,2))                        AS odd_lot_total_val,
    CAST(ma_in_sn.pt_total_vol AS int)                                       AS pt_total_vol,
    CAST(ma_in_sn.pt_total_val AS decimal(23,2))                             AS pt_total_val
FROM ma_in_sn
LEFT JOIN ma_in_di
    ON  ma_in_di.market_id = ma_in_sn.market_id
    AND ma_in_di.market_code = ma_in_sn.market_code
