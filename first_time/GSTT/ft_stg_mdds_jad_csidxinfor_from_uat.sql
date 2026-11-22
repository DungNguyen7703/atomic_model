-- [FIRST-TIME] ft_stg_mdds_jad_csidxinfor_from_uat: nap lich su MDDS tu Oracle UAT (UBCK.JAD_CSIDXINFOR_UAT) len staging PROD.
-- Ghi vao bang that prod_staging.mdds_stg.jad_csidxinfor (config ft_target, macro macros/first_time). Moi dong ghi vao partition data_dt = ngay giao dich (tradingdate dd/MM/yyyy);
-- INSERT OVERWRITE dynamic partition nen chay lai khong trung. Tuy chon chia nho: --vars '{backfill_from: "2026-01-01", backfill_to: "2026-01-31"}'.
/*
*--------------------------------------------------------------------*
* Program code: ft_stg_mdds_jad_csidxinfor_from_uat
* Program name: Staging MDDS.JAD_CSIDXINFOR (tu Oracle UAT)
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Keo du lieu da dump tu staging UAT len Oracle (UBCK.JAD_CSIDXINFOR) vao staging PROD. Cot/kieu theo DDL prod_staging.mdds_stg.jad_csidxinfor (10 cot nghiep vu + data_dt + ds_etl_pcs_tms); tradingdate giu STRING dd/MM/yyyy, data_dt = to_date(tradingdate).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                           AS id
    , CAST(adddate AS string)                      AS adddate
    , CAST(floorcode AS string)                    AS floorcode
    , CAST(indexcode AS string)                    AS indexcode
    , CAST(indexid AS bigint)                      AS indexid
    , CAST(stockno AS string)                      AS stockno
    , CAST(symbol AS string)                       AS symbol
    , CAST(totalqtty AS string)                    AS totalqtty
    , CAST(tradingdate AS string)                  AS tradingdate
    , CAST(weighted AS string)                     AS weighted
    , to_date(tradingdate, 'dd/MM/yyyy')              AS data_dt
FROM {{ source('source_mdds_uat', 'raw_jad_csidxinfor_uat') }}