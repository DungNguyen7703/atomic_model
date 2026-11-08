-- [FIRST-TIME] ft_atm_listed_share_information_vsdc_outstanding_shares: ban ephemeral cua atm_listed_share_information_vsdc_outstanding_shares cho bo first-time.
/*
*--------------------------------------------------------------------*
* Program code: atm_listed_share_information_vsdc_outstanding_shares
* Program name: Atomic Listed Share Info – VSDC.OUTSTANDING_SHARES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-22		tuan.nguyenvanb		[DONG BO DESIGN 2026-10-21] entity listed_share_info -> listed_share_information; cot listed_share_information_id,
*									issuer_name->issuer_nm, transaction_date->transaction_dt; them rpt_dt (REPORT_DATE, chi HNX/HOSE) o CUOI SELECT.
*									Bang vat ly: RENAME TABLE/COLUMN + ADD COLUMN rpt_dt AFTER transaction_dt (scratch/alter_atomic_rename_20261022.sql) TRUOC khi chay.
*--------------------------------------------------------------------*
*/

-- 2026-10-09 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)
WITH ou_sh AS (
    SELECT
        ticker_symbol
        , isin_code
        , total_issued_shares
        , treasury_shares
        , outstanding_shares
        , free_float_shares
        , restricted_shares
        , voting_shares
        , transaction_date
        , report_year
        , report_month
        , report_day
        , ds_snpst_dt
    FROM {{ ft_ref('ft_ods_vsdc_outstanding_shares') }}
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('VSDC_OUTSTANDING_SHARES', "ticker_symbol") }} AS listed_share_information_id
    , CAST(ticker_symbol AS string)                AS ticker_symbol
    , CAST('VSDC_OUTSTANDING_SHARES' AS string)    AS src_stm_code
    , CAST(isin_code AS string)                    AS isin_code
    , CAST(total_issued_shares AS bigint)          AS total_issued_share_quantity
    , CAST(treasury_shares AS bigint)              AS treasury_share_quantity
    , CAST(outstanding_shares AS bigint)           AS outstanding_share_quantity
    , CAST(free_float_shares AS bigint)            AS free_float_share_quantity
    , CAST(restricted_shares AS bigint)            AS restricted_share_quantity
    , CAST(voting_shares AS bigint)                AS voting_share_quantity
    , CAST(NULL AS string)                         AS issuer_nm
    , CAST(NULL AS bigint)                         AS listed_share_quantity
    , CAST(NULL AS decimal(23,2))                  AS reference_price
    , CAST(transaction_date AS date)               AS transaction_dt
    , CAST(report_year AS int)                     AS rpt_year
    , CAST(report_month AS int)                    AS rpt_month
    , CAST(report_day AS int)                      AS rpt_day
    , CAST(ds_snpst_dt AS date) AS ds_snpst_dt  -- [BACKFILL-UAT-NEW] cot ds_snpst_dt (first-time)
FROM ou_sh
