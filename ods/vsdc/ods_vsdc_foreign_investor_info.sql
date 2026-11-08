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
* 2026-10-25		tuan.nguyenvanb		[LLD VSDC_FOREIGN_INVESTOR_INFO] Them cot report_date (nguon STG da co) sau remaining_shares_foreign_can_hold. Can ALTER ODS.
* 2026-11-05		claude				[LLD VSDC_FOREIGN_INVESTOR_INFO] Thay report_date -> report_year/report_month/report_day (int) theo thiet ke dm_atm_foreign_ownership_information. Can ALTER ODS.
*--------------------------------------------------------------------*
*/

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
FROM {{ source('source_vsdc', 'raw_foreign_investor_info') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
