-- [FIRST-TIME] ft_stg_mdds_jad_tvhistory1d: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily stg_mdds_jad_tvhistory1d (config ft_target='jad_tvhistory1d', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_tvhistory1d
* Program name: Staging MDDS.JAD_TVHISTORY1D
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-15		tuan.nguyenvanb		Dong bo voi stg_mdds_jad_tvhistory1d daily: doi ten tu ft_stg_MDDS_JAD_TVHISTORY1D, 9 cot (tradingdate STRING dd/MM/yyyy, data_dt = ngay giao dich), ft_target jad_tvhistory1d.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                                AS id
    , CAST(close AS double)                           AS close
    , CAST(high AS double)                            AS high
    , CAST(low AS double)                             AS low
    , CAST(open AS double)                            AS open
    , CAST(symbol AS string)                          AS symbol
    , CAST(tradingdate AS string)                     AS tradingdate
    , CAST(volume AS decimal(19,0))                   AS volume
    , to_date(tradingdate, 'dd/MM/yyyy')  AS data_dt
FROM {{ source('source_mdds', 'raw_jad_tradingviewhistory1day') }}
-- [BACKFILL-UAT-ORIG] daily loc WHERE tradingdate = ngay chay; first-time lay toan bo lich su, khong loc ngay
