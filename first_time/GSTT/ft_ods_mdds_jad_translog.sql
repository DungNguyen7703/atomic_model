-- [FIRST-TIME] ft_ods_mdds_jad_translog: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_mdds_jad_translog (config ft_target='jad_translog', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_translog
* Program name: ODS MDDS.JAD_TRANSLOG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-11-15		tuan.nguyenvanb		Tao moi, dong bo SELECT (16 cot, thu tu + data_dt) voi ods_mdds_jad_translog; doc bang that prod_staging.mdds_stg.jad_translog
*									(ft_ref ft_stg_mdds_jad_translog). First-time lay toan bo lich su, khong loc ngay.
*--------------------------------------------------------------------*
*/

SELECT
    kid
    , boardid
    , changecolor
    , formattedaccval
    , formattedaccvol
    , formattedchangevalue
    , formattedmatchprice
    , formattedtime
    , formattedvol
    , lastcolor
    , sequencemsg
    , symbol
    , totalbuyvol
    , totalsellvol
    , tradingdate
    , data_dt
FROM {{ ft_ref('ft_stg_mdds_jad_translog') }}
-- [BACKFILL-UAT-ORIG] daily loc WHERE data_dt = ngay chay (bien ngay); first-time lay toan bo lich su, khong loc
