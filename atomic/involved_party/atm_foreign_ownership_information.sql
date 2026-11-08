/*
*--------------------------------------------------------------------*
* Program code: atm_foreign_ownership_information
* Program name: Atomic Foreign Ownership Information
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-25		tuan.nguyenvanb		[LLD atomic lld_VSDC_FOREIGN_INVESTOR_INFO.yaml] Doi cot foreign_ownership_info_id -> foreign_ownership_information_id; doi bang vat ly
*                                       foreign_ownership_info -> foreign_ownership_information (alias; ten model giu nguyen de khong vo ref).
*                                       Them cot rpt_dt (nguon report_date) sau remaining_foreign_holding_quantity; max_foreign_ownership_ratio
*                                       cast decimal(5,2). Can ALTER (snapshot - insert theo vi tri).
* 2026-11-05		claude				[LLD VSDC_FOREIGN_INVESTOR_INFO] Dong bo thiet ke dm_atm_foreign_ownership_information: bo rpt_dt, them rpt_year/rpt_month/rpt_day (int);
*                                       doi thu tu cot (src_stm_code truoc ticker_symbol). Can ALTER (snapshot - insert theo vi tri).
*--------------------------------------------------------------------*
*/

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
    FROM {{ ref('ods_vsdc_foreign_investor_info') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('VSDC_FOREIGN_INVESTOR_INFO', "ticker_symbol") }} AS foreign_ownership_information_id
    , CAST('VSDC_FOREIGN_INVESTOR_INFO' AS string)              AS src_stm_code
    , CAST(ticker_symbol AS string)                             AS ticker_symbol
    , CAST(isin_code AS string)                                 AS isin_code
    , CAST(total_issued_shares AS bigint)                       AS total_issued_share_quantity
    , CAST(max_foreign_ownership_ratio AS decimal(5,2))         AS max_foreign_ownership_ratio
    , CAST(max_shares_foreign_can_hold AS bigint)               AS max_foreign_holding_quantity
    , CAST(current_shares_foreign_hold AS bigint)               AS current_foreign_holding_quantity
    , CAST(remaining_shares_foreign_can_hold AS bigint)         AS remaining_foreign_holding_quantity
    , CAST(report_year AS int)                                  AS rpt_year
    , CAST(report_month AS int)                                 AS rpt_month
    , CAST(report_day AS int)                                   AS rpt_day
FROM fr_iv
