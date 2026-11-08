-- [FIRST-TIME] ft_dtm_fct_market_index_intraday: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_market_index_intraday (config ft_target='fct_market_index_intraday', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_market_index_intraday
* Program name: Dtm Fct Market Index Intraday
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-13		tuan.nguyenvanb		[PHUONG AN B] dong bo daily: gom theo phut (ban tin cuoi phut); doi ten cdr_dt_dim_id -> trade_dt_dim_id.
* 2026-10-08		tuan.nguyenvanb		[BACKFILL-UAT-NEW] TAM THOI: doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
*                                       Dong goc duoc giu o dang comment BACKFILL-UAT-ORIG. Chuyen che do daily bang dbt/first_time_mode.py [BACKFILL-UAT-NEW]
*                                       de tra ve nguyen ban sau khi chay xong du lieu 1 nam. [BACKFILL-UAT-NEW]
*--------------------------------------------------------------------*
*/

-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS-GSTT] TAM THOI chay MOT LUOT nhieu ngay (1 nam) cho UAT: bo loc etl_date, tra cuu theo tung ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
WITH ma_in_sn_raw AS (
    SELECT
        index_time,
        market_index_val,
        total_val,
        market_code,
        market_id,
        trading_dt,
        sequence
    FROM {{ ft_ref('ft_atm_market_index_snapshot') }}
    --WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

-- 2026-10-13 [PHUONG AN B, giong daily] 1 ban ghi / chi so / phut: ban tin cuoi cung trong phut (index_time desc, sequence desc)
ma_in_sn AS (
    SELECT
        index_time,
        market_index_val,
        total_val,
        market_code,
        market_id,
        trading_dt
    FROM (
        SELECT
            ma_in_sn_raw.*,
            ROW_NUMBER() OVER (
                PARTITION BY market_id, market_code, trading_dt, SUBSTR(index_time, 1, 5)
                ORDER BY index_time DESC, sequence DESC
            ) AS rn_minute
        FROM ma_in_sn_raw
    ) x
    WHERE rn_minute = 1
),

ma_in_di AS (
    SELECT
        market_index_dim_id,
        market_id,
        market_code,
        ds_snpst_dt   -- [FIRST-TIME 2026-10-17] dim ft_hstr_by_day: noi theo ngay
    -- [BACKFILL-UAT-ORIG] FROM {{ ft_ref('ft_dtm_market_index_dim') }}_hstr
    FROM {{ ft_ref('ft_dtm_market_index_dim') }}_hstr   -- [FIRST-TIME 2026-10-17]
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND ds_rcrd_st = 'ACTIVE'
    WHERE ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
)

SELECT
    CAST(ma_in_di.market_index_dim_id AS string)                             AS market_index_dim_id,
    CAST(date_format(ma_in_sn.trading_dt, 'yyyyMMdd') AS string)                                   AS trade_dt_dim_id,
    CAST(SUBSTR(ma_in_sn.index_time, 1, 5) AS string)                        AS index_time,   -- [2026-10-12] HH:mm giong daily
    CAST(ma_in_sn.market_index_val AS decimal(23,2))                         AS market_index_val_at_time,
    -- [BACKFILL-UAT-ORIG] ma_in_sn.total_val - LAG(ma_in_sn.total_val) OVER (PARTITION BY ma_in_sn.market_code ORDER BY ma_in_sn.index_time) AS total_val_at_time
    ma_in_sn.total_val AS total_val_at_time   -- [BACKFILL-UAT-NEW] [2026-10-20 BA] lay 1-1 total_val cua ban tin cuoi phut, khong tru LAG
FROM ma_in_sn
LEFT JOIN ma_in_di
    ON  ma_in_di.market_id = ma_in_sn.market_id
    AND ma_in_di.market_code = ma_in_sn.market_code
    AND ma_in_di.ds_snpst_dt = ma_in_sn.trading_dt   -- [FIRST-TIME 2026-10-17]
--WHERE ma_in_sn.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
