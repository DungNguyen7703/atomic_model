-- [FIRST-TIME] ft_atm_foreign_ownership_info: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_foreign_ownership_info (config ft_target='foreign_ownership_information', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: atm_foreign_ownership_info
* Program name: Atomic Foreign Ownership Info
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-25		tuan.nguyenvanb		[LLD VSDC_FOREIGN_INVESTOR_INFO] Dong bo atm_foreign_ownership_info: doi id -> foreign_ownership_information_id, them rpt_dt, ratio decimal(5,2); ft_target doi sang foreign_ownership_information.
* 2026-11-05		claude				[LLD VSDC_FOREIGN_INVESTOR_INFO] Dong bo thiet ke dm_atm_foreign_ownership_information: bo rpt_dt, them rpt_year/rpt_month/rpt_day (int);
*                                       doi thu tu cot (src_stm_code truoc ticker_symbol). Can ALTER (snapshot - insert theo vi tri).
*--------------------------------------------------------------------*
*/

-- 2026-10-09 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)
WITH fr_iv AS (
    SELECT
        ticker_symbol
        , isin_code
        , total_issued_shares
        , max_foreign_ownership_ratio
        , max_shares_foreign_can_hold
        , current_shares_foreign_hold
        , remaining_shares_foreign_can_hold
        , report_year
        , report_month
        , report_day
        , ds_snpst_dt
    FROM {{ ft_ref('ft_ods_vsdc_foreign_investor_info') }}
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('VSDC_FOREIGN_INVESTOR_INFO', "fr_iv.ticker_symbol") }} AS foreign_ownership_information_id
    , CAST('VSDC_FOREIGN_INVESTOR_INFO' AS string)              AS src_stm_code
    , CAST(fr_iv.ticker_symbol AS string)                       AS ticker_symbol
    , CAST(fr_iv.isin_code AS string)                           AS isin_code
    , CAST(fr_iv.total_issued_shares AS bigint)                 AS total_issued_share_quantity
    , CAST(fr_iv.max_foreign_ownership_ratio AS decimal(5,2))   AS max_foreign_ownership_ratio
    , CAST(fr_iv.max_shares_foreign_can_hold AS bigint)         AS max_foreign_holding_quantity
    , CAST(fr_iv.current_shares_foreign_hold AS bigint)         AS current_foreign_holding_quantity
    , CAST(fr_iv.remaining_shares_foreign_can_hold AS bigint)   AS remaining_foreign_holding_quantity
    , CAST(fr_iv.report_year AS int)                            AS rpt_year
    , CAST(fr_iv.report_month AS int)                           AS rpt_month
    , CAST(fr_iv.report_day AS int)                             AS rpt_day
    , CAST(fr_iv.ds_snpst_dt AS date) AS ds_snpst_dt  -- [BACKFILL-UAT-NEW] cot ds_snpst_dt (first-time)
FROM fr_iv
