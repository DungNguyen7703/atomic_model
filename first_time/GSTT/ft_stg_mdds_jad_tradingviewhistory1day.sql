-- [FIRST-TIME] ft_stg_mdds_jad_tradingviewhistory1day: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily stg_mdds_jad_tradingviewhistory1day (config ft_target='jad_tradingviewhistory1day', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_tradingviewhistory1day
* Program name: Staging MDDS.JAD_TRADINGVIEWHISTORY1DAY
* Created by: tuan.nguyenvanb
* Created date: 2026-09-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-30		tuan.nguyenvanb		Tao moi - phuc vu atm_market_price_snapshot (nhanh
*                                       nen ngay), theo BRD brd_MDDS_JAD_TRADINGVIEWHISTORY1DAY
*                                       (TRADINGDATE dinh dang dd/MM/yyyy).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                    AS id
    , CAST(symbol AS string)              AS symbol
    , to_date(tradingdate, 'dd/MM/yyyy')  AS tradingdate
    , CAST(open AS double)                AS open
    , CAST(high AS double)                AS high
    , CAST(low AS double)                 AS low
    , CAST(close AS double)               AS close
    , CAST(volume AS bigint)              AS volume
FROM {{ source('source_mdds', 'raw_jad_tradingviewhistory1day') }}
-- [BACKFILL-UAT-ORIG] WHERE date_format(to_date(TRADINGDATE,'dd/MM/yyyy'), 'yyyy-MM-dd') BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]
