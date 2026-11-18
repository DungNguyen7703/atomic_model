-- [FIRST-TIME] ft_ods_mdds_jad_csidxinfor: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_mdds_jad_csidxinfor (config ft_target='jad_csidxinfor', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_csidxinfor
* Program name: ODS MDDS.JAD_CSIDXINFOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , indexcode
    , symbol
    , totalqtty
    , adddate
    , indexid
    , floorcode
    , tradingdate
    , stockno
    , weighted
FROM {{ ft_ref('ft_stg_mdds_jad_csidxinfor') }}
-- [BACKFILL-UAT-ORIG] WHERE TRADINGDATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]