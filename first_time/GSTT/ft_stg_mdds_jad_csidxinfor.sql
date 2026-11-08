-- [FIRST-TIME] ft_stg_mdds_jad_csidxinfor: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily stg_mdds_jad_csidxinfor (config ft_target='jad_csidxinfor', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_csidxinfor
* Program name: Staging MDDS.JAD_CSIDXINFOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)            AS id
    , CAST(indexcode AS string)   AS indexcode
    , CAST(symbol AS string)      AS symbol
    , CAST(totalqtty AS string)   AS totalqtty
    , CAST(adddate AS string)     AS adddate
    , CAST(indexid AS int)        AS indexid
    , CAST(floorcode AS string)   AS floorcode
    , to_date(tradingdate, 'dd/MM/yyyy') AS tradingdate
    , CAST(stockno AS string)     AS stockno
    , CAST(weighted AS string)    AS weighted
FROM {{ source('source_mdds', 'raw_jad_csidxinfor') }}
-- [BACKFILL-UAT-ORIG] WHERE date_format(to_date(TRADINGDATE,'dd/MM/yyyy'), 'yyyy-MM-dd') BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]