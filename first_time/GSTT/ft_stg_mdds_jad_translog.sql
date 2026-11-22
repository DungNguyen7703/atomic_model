-- [FIRST-TIME] ft_stg_mdds_jad_translog: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily stg_mdds_jad_translog (config ft_target='jad_translog', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_translog
* Program name: Staging MDDS.JAD_TRANSLOG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-15		tuan.nguyenvanb		Tao moi theo stg_mdds_jad_translog daily (16 cot, data_dt = ngay giao dich), doc Oracle goc, khong loc ngay.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(kid AS string)                               AS kid
    , CAST(boardid AS string)                         AS boardid
    , CAST(changecolor AS string)                     AS changecolor
    , CAST(formattedaccval AS double)                 AS formattedaccval
    , CAST(formattedaccvol AS decimal(19,0))          AS formattedaccvol
    , CAST(formattedchangevalue AS double)            AS formattedchangevalue
    , CAST(formattedmatchprice AS double)             AS formattedmatchprice
    , CAST(formattedtime AS string)                   AS formattedtime
    , CAST(formattedvol AS decimal(19,0))             AS formattedvol
    , CAST(lastcolor AS string)                       AS lastcolor
    , CAST(sequencemsg AS string)                     AS sequencemsg
    , CAST(symbol AS string)                          AS symbol
    , CAST(totalbuyvol AS decimal(19,0))              AS totalbuyvol
    , CAST(totalsellvol AS decimal(19,0))             AS totalsellvol
    , CAST(tradingdate AS string)                     AS tradingdate
    , to_date(tradingdate, 'dd/MM/yyyy')  AS data_dt
FROM {{ source('source_mdds', 'raw_jad_translog') }}
-- [BACKFILL-UAT-ORIG] daily loc WHERE tradingdate = ngay chay; first-time lay toan bo lich su, khong loc ngay
