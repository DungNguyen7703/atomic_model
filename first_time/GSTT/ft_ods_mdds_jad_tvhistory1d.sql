-- [FIRST-TIME] ft_ods_mdds_jad_tvhistory1d: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_mdds_jad_tvhistory1d (config ft_target='jad_tvhistory1d', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_tvhistory1d
* Program name: ODS MDDS.JAD_TRADINGVIEWHISTORY1DAY
* Created by: tuan.nguyenvanb
* Created date: 2026-09-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-30		tuan.nguyenvanb		Tao moi - phuc vu atm_market_price_snapshot (nen ngay)
* 2026-11-15		tuan.nguyenvanb		Dong bo voi ods_mdds_jad_tvhistory1d daily: them cot data_dt (cuoi SELECT), doc bang that staging (ft_ref ft_stg_mdds_jad_tvhistory1d), partition data_dt.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , close
    , high
    , low
    , open
    , symbol
    , tradingdate
    , volume
    , data_dt
FROM {{ ft_ref('ft_stg_mdds_jad_tvhistory1d') }}
-- [BACKFILL-UAT-ORIG] daily loc WHERE data_dt = ngay chay; first-time lay toan bo lich su, khong loc
