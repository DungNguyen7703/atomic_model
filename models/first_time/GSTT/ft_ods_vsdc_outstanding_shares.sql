-- [FIRST-TIME] ft_ods_vsdc_outstanding_shares: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_vsdc_outstanding_shares (config ft_target='outstanding_shares', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_outstanding_shares
* Program name: ODS VSDC.OUTSTANDING_SHARES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

-- 2026-10-09 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
SELECT
    CAST(ticker_symbol AS string)          AS ticker_symbol
    , CAST(total_issued_shares AS bigint)  AS total_issued_shares
    , CAST(treasury_shares AS bigint)      AS treasury_shares
    , CAST(outstanding_shares AS bigint)   AS outstanding_shares
    , CAST(free_float_shares AS bigint)    AS free_float_shares
    , CAST(restricted_shares AS bigint)    AS restricted_shares
    , CAST(voting_shares AS bigint)        AS voting_shares
    , CAST(isin_code AS string)            AS isin_code
    , CAST(transaction_date AS date)       AS transaction_dt
    , CAST(report_day AS int)              AS report_day
    , CAST(report_month AS int)            AS report_month
    , CAST(report_year AS int)             AS report_year
    , CAST(transaction_date AS date)       AS ds_snpst_dt
FROM {{ source('source_vsdc', 'raw_outstanding_shares') }}
-- [BACKFILL-UAT-ORIG] WHERE transaction_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')