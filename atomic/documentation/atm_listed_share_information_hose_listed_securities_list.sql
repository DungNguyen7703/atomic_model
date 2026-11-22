/*
*--------------------------------------------------------------------*
* Program code: atm_listed_share_information_hose_listed_securities_list
* Program name: Atomic Listed Share Info – HOSE.LISTED_SECURITIES_LIST
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-18		tuan.nguyenvanb		ODS HOSE bo report_date, doi partition data_dt: doc ODS theo data_dt; THEM transaction_dt = NULL theo LLD - truoc day thieu cot nay nen lech so cot voi VSDC/HNX trong UNION ALL atm_listed_share_information.
*
* 2026-10-22		tuan.nguyenvanb		[DONG BO DESIGN 2026-10-21] entity listed_share_info -> listed_share_information; cot listed_share_information_id,
*									issuer_name->issuer_nm, transaction_date->transaction_dt; them rpt_dt (REPORT_DATE, chi HNX/HOSE) o CUOI SELECT.
*									Bang vat ly: RENAME TABLE/COLUMN + ADD COLUMN rpt_dt AFTER transaction_dt (scratch/alter_atomic_rename_20261022.sql) TRUOC khi chay.
* 2026-11-05		claude				[LLD HOSE.LISTED_SECURITIES_LIST] Dong bo thiet ke dm_atm_listed_share_information: bo rpt_dt, them rpt_year/rpt_month/rpt_day (int);
*									doi thu tu cot (src_stm_code truoc ticker_symbol). Can ALTER (snapshot - insert theo vi tri).
*--------------------------------------------------------------------*
*/

WITH lst_sec AS (
    SELECT
        ticker_symbol
        , issuer_name
        , listed_shares
        , outstanding_shares
        , reference_price
        , report_year
        , report_month
        , report_day
    FROM {{ ref('ods_hose_listed_securities_list') }}
    WHERE data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')   -- [2026-11-18] ODS doi sang append partition data_dt
)

SELECT
    {{ generate_surrogate_key_bigint('HOSE_LISTED_SECURITIES_LIST', "ticker_symbol") }} AS listed_share_information_id
    , CAST('HOSE_LISTED_SECURITIES_LIST' AS string) AS src_stm_code
    , CAST(ticker_symbol AS string) AS ticker_symbol
    , CAST(NULL AS string) AS isin_code
    , CAST(NULL AS bigint) AS total_issued_share_quantity
    , CAST(NULL AS bigint) AS treasury_share_quantity
    , CAST(outstanding_shares AS bigint) AS outstanding_share_quantity
    , CAST(NULL AS bigint) AS free_float_share_quantity
    , CAST(NULL AS bigint) AS restricted_share_quantity
    , CAST(NULL AS bigint) AS voting_share_quantity
    , CAST(NULL AS date) AS transaction_dt   -- [2026-11-18] LLD entity listed_share_information: HNX/HOSE khong map transaction_dt (null)   (truoc day THIEU cot nay -> lech so cot UNION ALL)
    , CAST(report_year AS int) AS rpt_year
    , CAST(report_month AS int) AS rpt_month
    , CAST(report_day AS int) AS rpt_day
    , CAST(issuer_name AS string) AS issuer_nm
    , CAST(listed_shares AS bigint) AS listed_share_quantity
    , CAST(reference_price AS decimal(23,2)) AS reference_price
FROM lst_sec
