-- [FIRST-TIME] ft_ods_mdds_jad_tradingviewhistory1day: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_mdds_jad_tradingviewhistory1day (config ft_target='jad_tradingviewhistory1day', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_tradingviewhistory1day
* Program name: ODS MDDS.JAD_TRADINGVIEWHISTORY1DAY
* Created by: tuan.nguyenvanb
* Created date: 2026-09-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-30		tuan.nguyenvanb		Tao moi - phuc vu atm_market_price_snapshot (nen ngay)
*--------------------------------------------------------------------*
*/

SELECT
    id
    , symbol
    , tradingdate
    , open
    , high
    , low
    , close
    , volume
FROM {{ ft_ref('ft_stg_mdds_jad_tradingviewhistory1day') }}
-- [BACKFILL-UAT-ORIG] WHERE TRADINGDATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]
