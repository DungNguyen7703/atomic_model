-- [FIRST-TIME] ft_dtm_fct_market_index_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_market_index_snpst (config ft_target='fct_market_index_snpst', macro macros/first_time).
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
*                                       Bo sung 15 cot open/high/low/prior_index,
*                                       index_change, index_percent_change, advances/
*                                       declines/no_change_count, ceiling/floor_count,
*                                       odd_lot_total_vol/val, pt_total_vol/val - da co
*                                       san trong atm_market_index_snapshot, dang bi
*                                       qlkd_fct_market_index_snpst_flat doc nhung chua
*                                       ton tai o day (UNRESOLVED_COLUMN).
*--------------------------------------------------------------------*
*/

-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS-GSTT] Ban FIRST-TIME cua model QLKD (nap 1 nam trong 1 lan chay): bo loc etl_date, doc dim tu bang MAIN. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
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
        row_number() over (partition by market_id, market_code, trading_dt order by index_time desc, sequence desc) as rn
    FROM {{ ft_ref('ft_atm_market_index_snapshot') }}
    -- [BACKFILL-UAT-ORIG] WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
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
    -- [BACKFILL-UAT-ORIG] FROM {{ ft_ref('ft_dtm_market_index_dim') }}_hstr
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND ds_rcrd_st = 'ACTIVE'
    -- [FIRST-TIME 2026-10-17] dim da ft_hstr_by_day (1 snapshot/ngay): doc _hstr va noi theo ds_snpst_dt = trading_dt
    -- (truoc day doc bang MAIN voi ACTIVE nen chi so DOI TEN market_id/ngung ve sau - HNXLCap, UPCOMLarge/Medium/Small,
    -- VNDIVIDEND, VNSHINE, VNMITECH, VN50GROWTH - bi INACTIVE o MAIN -> market_index_dim_id NULL cac ngay cu).
    , ds_snpst_dt
    FROM {{ ft_ref('ft_dtm_market_index_dim') }}_hstr   -- [FIRST-TIME 2026-10-17]
    WHERE ds_rcrd_st = 'ACTIVE'   -- [FIRST-TIME 2026-10-17]
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
    AND ma_in_di.ds_snpst_dt = ma_in_sn.trading_dt   -- [FIRST-TIME 2026-10-17] dim theo dung ngay snapshot
