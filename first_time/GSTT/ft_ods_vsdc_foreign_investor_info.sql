-- [FIRST-TIME] ft_ods_vsdc_foreign_investor_info: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_vsdc_foreign_investor_info (config ft_target='foreign_investor_info', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_foreign_investor_info
* Program name: ODS VSDC.FOREIGN_INVESTOR_INFO
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-25		tuan.nguyenvanb		[LLD VSDC_FOREIGN_INVESTOR_INFO] Them cot report_date (dong bo ods_vsdc_foreign_investor_info).
* 2026-11-05		claude				[LLD VSDC_FOREIGN_INVESTOR_INFO] Thay report_date -> report_year/report_month/report_day (int) theo thiet ke dm_atm_foreign_ownership_information. Can ALTER ODS.
*--------------------------------------------------------------------*
*/

-- 2026-10-09 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
SELECT
    CAST(ticker_symbol AS string)                        AS ticker_symbol
    , CAST(isin_code AS string)                          AS isin_code
    , CAST(total_issued_shares AS bigint)                AS total_issued_shares
    , CAST(max_foreign_ownership_ratio AS decimal(10,2)) AS max_foreign_ownership_ratio
    , CAST(max_shares_foreign_can_hold AS bigint)        AS max_shares_foreign_can_hold
    , CAST(current_shares_foreign_hold AS bigint)        AS current_shares_foreign_hold
    , CAST(remaining_shares_foreign_can_hold AS bigint)  AS remaining_shares_foreign_can_hold
    , CAST(report_day AS string)                         AS report_day
    , CAST(report_month AS string)                       AS report_month
    , CAST(report_year AS string)                        AS report_year
    , CAST(ds_snpst_dt AS date)                          AS ds_snpst_dt
FROM {{ source('source_vsdc', 'raw_foreign_investor_info') }}
-- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
