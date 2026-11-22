-- [FIRST-TIME] ft_stg_mdds_jad_translog_from_uat: nap lich su MDDS tu Oracle UAT (UBCK.JAD_TRANSLOG_UAT) len staging PROD.
-- Ghi vao bang that prod_staging.mdds_stg.jad_translog (config ft_target, macro macros/first_time). Moi dong ghi vao partition data_dt = ngay giao dich (tradingdate dd/MM/yyyy);
-- INSERT OVERWRITE dynamic partition nen chay lai khong trung. Tuy chon chia nho: --vars '{backfill_from: "2026-01-01", backfill_to: "2026-01-31"}'.
/*
*--------------------------------------------------------------------*
* Program code: ft_stg_mdds_jad_translog_from_uat
* Program name: Staging MDDS.JAD_TRANSLOG (tu Oracle UAT)
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Keo du lieu da dump tu staging UAT len Oracle (UBCK.JAD_TRANSLOG_UAT) vao staging PROD. Cot/kieu theo DDL prod_staging.mdds_stg.jad_translog (15 cot nghiep vu + data_dt + ds_etl_pcs_tms); tradingdate giu STRING dd/MM/yyyy, data_dt = to_date(tradingdate).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(kid AS string)                          AS kid
    , CAST(boardid AS string)                      AS boardid
    , CAST(changecolor AS string)                  AS changecolor
    , CAST(formattedaccval AS double)              AS formattedaccval
    , CAST(formattedaccvol AS decimal(19,0))       AS formattedaccvol
    , CAST(formattedchangevalue AS double)         AS formattedchangevalue
    , CAST(formattedmatchprice AS double)          AS formattedmatchprice
    , CAST(formattedtime AS string)                AS formattedtime
    , CAST(formattedvol AS decimal(19,0))          AS formattedvol
    , CAST(lastcolor AS string)                    AS lastcolor
    , CAST(sequencemsg AS string)                  AS sequencemsg
    , CAST(symbol AS string)                       AS symbol
    , CAST(totalbuyvol AS decimal(19,0))           AS totalbuyvol
    , CAST(totalsellvol AS decimal(19,0))          AS totalsellvol
    , CAST(tradingdate AS string)                  AS tradingdate
    , to_date(tradingdate, 'dd/MM/yyyy')              AS data_dt
FROM {{ source('source_mdds_uat', 'raw_jad_translog_uat') }}