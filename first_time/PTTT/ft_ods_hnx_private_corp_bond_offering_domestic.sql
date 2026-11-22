-- [FIRST-TIME] ft_ods_hnx_private_corp_bond_offering_domestic: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_hnx_private_corp_bond_offering_domestic (config ft_target='private_corp_bond_offering_domestic', macro macros/first_time). Partition data_dt (append dynamic overwrite).
/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_private_corp_bond_offering_domestic
* Program name: ODS HNX.PRIVATE_CORP_BOND_OFFERING_DOMESTIC
* Created by: tuan.nguyenvanb
* Created date: 2026-11-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-18		tuan.nguyenvanb		[MOI] STG PROD tach private_corp_bond_offering thanh 2 bang (trong nuoc / quoc te) -> 1 ODS rieng / bang,
*										keo 1-1 cot nghiep vu cua prod_staging.hnx_stg.private_corp_bond_offering_domestic (giu nguyen kieu STG), loc STG theo ds_snpst_dt = etl_date (doc cham, da chap nhan); append, partition data_dt (cot cuoi -- 2026-11-18 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
SELECT).
*										Gop 2 bang o tang atomic theo thiet ke (chua lam).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(posting_date AS date)                 AS posting_date
    , CAST(issuer_name AS string)                AS issuer_name
    , CAST(business_no AS string)                AS business_no
    , CAST(enterprise_type AS string)            AS enterprise_type
    , CAST(business_sector AS string)            AS business_sector
    , CAST(bond_code AS string)                  AS bond_code
    , CAST(term_unit AS string)                  AS term_unit
    , CAST(term AS int)                          AS term
    , CAST(issue_date AS date)                   AS issue_date
    , CAST(maturity_date AS date)                AS maturity_date
    , CAST(remaining_term AS int)                AS remaining_term
    , CAST(offering_volume AS bigint)            AS offering_volume
    , CAST(par_value AS decimal(30,6))           AS par_value
    , CAST(interest_payment_type AS string)      AS interest_payment_type
    , CAST(interest_rate_type AS string)         AS interest_rate_type
    , CAST(interest_payment_method AS string)    AS interest_payment_method
    , CAST(repurchase_and_swap AS string)        AS repurchase_and_swap
    , CAST(issue_interest_rate AS decimal(20,10)) AS issue_interest_rate
    , CAST(convertible_bond AS string)           AS convertible_bond
    , CAST(warrant_linked_bond AS string)        AS warrant_linked_bond
    , CAST(secured_bond AS string)               AS secured_bond
    , CAST(report_year AS int)                   AS report_year
    , CAST(report_month AS int)                  AS report_month
    , CAST(report_day AS int)                    AS report_day
    , CAST(report_period AS string)              AS report_period
    , CAST(data_dt AS date)                      AS data_dt   -- cot partition (append) - dat CUOI SELECT
FROM {{ source('source_hnx', 'raw_private_corp_bond_offering_domestic') }}
-- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
