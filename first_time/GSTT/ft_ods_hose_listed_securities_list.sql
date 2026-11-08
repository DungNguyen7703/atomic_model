-- [FIRST-TIME] ft_ods_hose_listed_securities_list: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_hose_listed_securities_list (config ft_target='listed_securities_list', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_hose_listed_securities_list
* Program name: ODS HOSE.LISTED_SECURITIES_LIST
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
    CAST(ticker_symbol AS string)            AS ticker_symbol
    , CAST(issuer_name AS string)            AS issuer_name
    , CAST(listed_shares AS bigint)          AS listed_shares
    , CAST(outstanding_shares AS bigint)     AS outstanding_shares
    , CAST(reference_price AS decimal(23,2)) AS reference_price
    , CAST(report_date AS date)              AS report_date
    , CAST(report_day AS int)                AS report_day
    , CAST(report_month AS int)              AS report_month
    , CAST(report_year AS int)               AS report_year
    , CAST(ds_snpst_dt AS date)              AS ds_snpst_dt
FROM {{ source('source_hose', 'raw_listed_securities_list_hose') }}
-- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
