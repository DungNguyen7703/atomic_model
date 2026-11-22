-- [FIRST-TIME] ft_atm_open_investor_account: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_open_investor_account (config ft_target='open_investor_account', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: atm_open_investor_account
* Program name: Atomic Open Investor Account
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-16		tuan.nguyenvanb		Tao moi theo atm_open_investor_account daily (17 cot, partition open_dt): doc ft_ods_vsdc_open_investors, bo loc open_date = etl_date.
*--------------------------------------------------------------------*
*/

WITH investor AS (
    SELECT
        trading_account_no
        , customer_name
        , investor_type
        , address
        , id_number
        , issue_date
        , issue_place
        , open_date
        , nationality
        , phone_number
        , email
        , report_year
        , report_month
        , report_day
    FROM {{ ft_ref('ft_ods_vsdc_open_investors') }}
    -- [BACKFILL-UAT-ORIG] WHERE open_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')   -- daily loc ngay; first-time lay toan bo lich su
)

SELECT
    {{ generate_surrogate_key('VSDC_OPEN_INVESTORS', "trading_account_no") }} AS open_investor_account_id
    , CAST('VSDC_OPEN_INVESTORS' AS string)                                   AS src_stm_code
    , CAST(trading_account_no AS string)                                      AS investor_account_nbr
    , CAST(customer_name AS string)                                           AS investor_nm
    , CAST(investor_type AS string)                                           AS investor_tp_code
    , CAST(address AS string)                                                 AS adr
    , CAST(id_number AS string)                                               AS identification_nbr
    , CAST(issue_date AS date)                                                AS issue_dt
    , CAST(issue_place AS string)                                             AS issue_place
    , CAST(open_date AS date)                                                 AS open_dt
    , {{ generate_surrogate_key('VSDC_NATIONALITY', "nationality") }}         AS nationality_id
    , CAST(nationality AS int)                                                AS nationality_code
    , CAST(phone_number AS string)                                            AS phone_nbr
    , CAST(email AS string)                                                   AS email
    , CAST(report_year AS int)                                                AS rpt_year
    , CAST(report_month AS int)                                               AS rpt_month
    , CAST(report_day AS int)                                                 AS rpt_day
FROM investor
