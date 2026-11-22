-- [FIRST-TIME] ft_stg_mdds_jad_tvhistory1m_from_uat: nap lich su MDDS tu Oracle UAT (UBCK.JAD_TVHISTORY1M_UAT) len staging PROD.
-- Ghi vao bang that prod_staging.mdds_stg.jad_tvhistory1m (config ft_target, macro macros/first_time). Moi dong ghi vao partition data_dt = ngay giao dich (tradingdate dd/MM/yyyy);
-- INSERT OVERWRITE dynamic partition nen chay lai khong trung. Tuy chon chia nho: --vars '{backfill_from: "2026-01-01", backfill_to: "2026-01-31"}'.
/*
*--------------------------------------------------------------------*
* Program code: ft_stg_mdds_jad_tvhistory1m_from_uat
* Program name: Staging MDDS.JAD_TVHISTORY1M (tu Oracle UAT)
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Keo du lieu da dump tu staging UAT len Oracle (UBCK.JAD_TVHISTORY1M_UAT) vao staging PROD. Cot/kieu theo DDL prod_staging.mdds_stg.jad_tvhistory1m (9 cot nghiep vu + data_dt + ds_etl_pcs_tms); tradingdate giu STRING dd/MM/yyyy, data_dt = to_date(tradingdate).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                           AS id
    , CAST(close AS double)                        AS close
    , CAST(high AS double)                         AS high
    , CAST(low AS double)                          AS low
    , CAST(minute AS string)                       AS minute
    , CAST(open AS double)                         AS open
    , CAST(symbol AS string)                       AS symbol
    , CAST(tradingdate AS string)                  AS tradingdate
    , CAST(volume AS decimal(19,0))                AS volume
    , to_date(tradingdate, 'dd/MM/yyyy')              AS data_dt
FROM {{ source('source_mdds_uat', 'raw_jad_tvhistory1m_uat') }}