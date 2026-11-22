-- [FIRST-TIME] ft_ods_hnx_private_corp_bond_registration: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_hnx_private_corp_bond_registration (config ft_target='private_corp_bond_registration', macro macros/first_time). Partition data_dt (append dynamic overwrite).
/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_private_corp_bond_registration
* Program name: ODS HNX.PRIVATE_CORP_BOND_REGISTRATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-18		tuan.nguyenvanb		Khop DDL prod_staging.hnx_stg.private_corp_bond_registration: giu loc STG theo ds_snpst_dt = etl_date (doc cham, da chap nhan); doi snapshot -> append, partition data_dt (cot cuoi -- 2026-11-18 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
SELECT).
* 2026-10-15		tuan.nguyenvanb		[FIX] Them cot business_no cho khop bang vat ly (loi INSERT_COLUMN_ARITY_MISMATCH).
*
*--------------------------------------------------------------------*
* 2026-10-19		tuan.nguyenvanb		[LLD atomic HNX_PRIVATE_CORP_BOND_*] Them cot report_day, report_year (cuoi bang, sau business_no) de atomic
*									bo sung rpt_day/rpt_year. Can ALTER ODS ADD COLUMN ... AFTER business_no (insert theo vi tri).
*/

SELECT
    CAST(bond_code AS string)                                AS bond_code
    , CAST(currency AS string)                                AS currency
    , CAST(issuer_name AS string)                             AS issuer_name
    , CAST(par_value AS decimal(18,2))                        AS par_value
    , CAST(term_unit AS string)                               AS term_unit
    , CAST(remaining_term AS int)                             AS remaining_term
    , CAST(issue_date AS date)                                AS issue_date
    , CAST(maturity_date AS date)                             AS maturity_date
    , CAST(interest_payment_method AS string)                 AS interest_payment_method
    , CAST(interest_payment_term AS string)                   AS interest_payment_term
    , CAST(issued_volume AS bigint)                           AS issued_volume
    , CAST(repurchased_converted_swapped_volume AS bigint)    AS repurchased_converted_swapped_volume
    , CAST(registered_trading_volume AS bigint)               AS registered_trading_volume
    , CAST(outstanding_volume AS bigint)                      AS outstanding_volume
    , CAST(issue_interest_rate AS decimal(10,2))              AS issue_interest_rate
    , CAST(first_trading_date AS date)                        AS first_trading_date
    , CAST(report_month AS string)                            AS report_month
    , CAST(business_no AS string)                             AS business_no
    , CAST(report_day AS string)                              AS report_day
    , CAST(report_year AS string)                             AS report_year
    , CAST(data_dt AS date)                                   AS data_dt   -- [2026-11-18] cot partition (append) - dat CUOI SELECT
FROM {{ source('source_hnx', 'raw_private_corp_bond_registration') }}
-- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
