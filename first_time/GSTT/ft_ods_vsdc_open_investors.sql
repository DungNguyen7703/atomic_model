-- [FIRST-TIME] ft_ods_vsdc_open_investors: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_vsdc_open_investors (config ft_target='open_investors', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_open_investors
* Program name: ODS VSDC.OPEN_INVESTORS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-16		tuan.nguyenvanb		Tao moi theo ods_vsdc_open_investors daily (15 cot gom report_year/month/day), bo loc open_date = etl_date, doc source_vsdc.raw_open_investors,
*                                       partition open_date nhu daily.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(customer_name AS string)          AS customer_name
    , CAST(investor_type AS int)           AS investor_type   -- [2026-11-18] dong bo daily/DDL ODS (INT); truoc la string -> loi CANNOT_SAFELY_CAST
    , CAST(trading_account_no AS string)   AS trading_account_no
    , CAST(address AS string)              AS address
    , CAST(id_number AS string)            AS id_number
    , CAST(issue_date AS date)             AS issue_date
    , CAST(issue_place AS string)          AS issue_place
    , CAST(open_date AS date)              AS open_date
    , CAST(nationality AS int)             AS nationality     -- [2026-11-18] dong bo daily/DDL ODS (INT)
    , CAST(phone_number AS string)         AS phone_number
    , CAST(email AS string)                AS email
    , CAST(notes AS string)                AS notes
    , CAST(report_year AS int)             AS report_year
    , CAST(report_month AS int)            AS report_month
    , CAST(report_day AS int)              AS report_day
FROM {{ source('source_vsdc', 'raw_open_investors') }}
-- [BACKFILL-UAT-ORIG] WHERE open_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')   -- daily loc ngay; first-time lay toan bo lich su, khong loc
