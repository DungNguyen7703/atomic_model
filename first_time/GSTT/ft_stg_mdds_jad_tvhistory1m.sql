-- [FIRST-TIME] ft_stg_mdds_jad_tvhistory1m: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily stg_mdds_jad_tvhistory1m (config ft_target='jad_tvhistory1m', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_tvhistory1m
* Program name: Staging MDDS.JAD_TVHISTORY1M
* Created by: tuan.nguyenvanb
* Created date: 2026-09-09
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-09		tuan.nguyenvanb		Tao moi - phuc vu atm_market_price_snapshot
*                                       (LLD DTM_GSTT_fct_security_trading_intraday
*                                       sua 2026-09-07, doi nguon sang market_price_snapshot)
*--------------------------------------------------------------------*
*/

/*
GIA DINH CHUA XAC NHAN:
- TRADINGDATE (varchar2(255)) gia dinh dinh dang 'dd/MM/yyyy' - cung quy uoc voi
  JAD_STOCKINFOR/cac bang JAD_* khac cung ho MDDS adapter. Chua co mau du lieu that
  de doi chieu tai thoi diem code.
- MINUTE (varchar2(255), nullable) gia dinh la processing_time dang 'HH:mm' (theo LLD
  DTM_GSTT_fct_security_trading_intraday mo ta "processing_time da chuan hoa HH:mm san
  tu ODS"). CAN Data Modeler/DBA profile lai gia tri that truoc khi tin dung cho production
  - neu dinh dang khac se can sua lai buoc parse o ODS (xem ods_mdds_jad_tvhistory1m.sql).
*/

SELECT
    CAST(id AS string)                    AS id
    , CAST(close AS double)               AS close
    , CAST(high AS double)                AS high
    , CAST(low AS double)                 AS low
    , CAST(minute AS string)              AS minute
    , CAST(open AS double)                AS open
    , CAST(symbol AS string)              AS symbol
    , to_date(tradingdate, 'dd/MM/yyyy')  AS tradingdate
    , CAST(volume AS bigint)              AS volume
FROM {{ source('source_mdds', 'raw_jad_tvhistory1m') }}
-- [BACKFILL-UAT-ORIG] WHERE date_format(to_date(TRADINGDATE,'dd/MM/yyyy'), 'yyyy-MM-dd') BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]
