-- [FIRST-TIME] ft_ods_mdds_jad_tvhistory1m: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_mdds_jad_tvhistory1m (config ft_target='jad_tvhistory1m', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_tvhistory1m
* Program name: ODS MDDS.JAD_TVHISTORY1M
* Created by: tuan.nguyenvanb
* Created date: 2026-09-09
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-09		tuan.nguyenvanb		Tao moi - phuc vu atm_market_price_snapshot
*--------------------------------------------------------------------*
*/

SELECT
    id
    , symbol
    , tradingdate
    , minute
    , open
    , high
    , low
    , close
    , volume
FROM {{ ft_ref('ft_stg_mdds_jad_tvhistory1m') }}
-- [BACKFILL-UAT-ORIG] WHERE TRADINGDATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]
