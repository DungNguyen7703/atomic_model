-- [FIRST-TIME] ft_atm_private_corp_bond_registration: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_private_corp_bond_registration (config ft_target='private_corp_bond_registration', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: atm_private_corp_bond_registration
* Program name: Atomic Private Corp Bond Registration
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* 2026-10-19		tuan.nguyenvanb		[LLD atomic lld_HNX_PRIVATE_CORP_BOND_REGISTRATION.yaml] Doi ten cot theo LLD: issuer_name->issuer_nm, par_value->
*									par_val, issue_date->issue_dt, maturity_date->maturity_dt, first_trading_date->first_trading_dt,
*									report_month->rpt_month; them rpt_day, rpt_year, business_nbr (sau rpt_month, cuoi bang).
*/

-- 2026-11-18 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): doc ft_ods_hnx_private_corp_bond_registration, bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
WITH pr_re AS (
    SELECT
        bond_code
        , currency
        , issuer_name
        , par_value
        , term_unit
        , remaining_term
        , issue_date
        , maturity_date
        , interest_payment_method
        , interest_payment_term
        , issued_volume
        , repurchased_converted_swapped_volume
        , registered_trading_volume
        , outstanding_volume
        , issue_interest_rate
        , first_trading_date
        , report_month
        , report_day
        , report_year
        , business_no
        , data_dt
    FROM {{ ft_ref('ft_ods_hnx_private_corp_bond_registration') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_PRIVATE_CORP_BOND_REGISTRATION', "pr_re.bond_code") }} AS private_corp_bond_registration_id
    , CAST('HNX_PRIVATE_CORP_BOND_REGISTRATION' AS string) AS src_stm_code
    , CAST(pr_re.bond_code AS string) AS bond_code
    , CAST(pr_re.currency AS string) AS currency_code
    , CAST(pr_re.issuer_name AS string) AS issuer_nm
    , CAST(pr_re.business_no AS string) AS business_nbr
    , CAST(pr_re.par_value AS bigint) AS par_val
    , CAST(pr_re.term_unit AS string) AS bond_term_unit
    , CAST(pr_re.remaining_term AS int) AS remaining_bond_term
    , CAST(pr_re.issue_date AS date) AS issue_dt
    , CAST(pr_re.maturity_date AS date) AS maturity_dt
    , CAST(pr_re.interest_payment_method AS string) AS interest_payment_method
    , CAST(pr_re.interest_payment_term AS string) AS interest_payment_term
    , CAST(pr_re.issued_volume AS bigint) AS issued_bond_vol
    , CAST(pr_re.repurchased_converted_swapped_volume AS bigint) AS repurchased_converted_swapped_bond_quantity
    , CAST(pr_re.registered_trading_volume AS bigint) AS registered_trading_bond_quantity
    , CAST(pr_re.outstanding_volume AS bigint) AS outstanding_bond_quantity
    , CAST(pr_re.issue_interest_rate AS decimal(5,2)) AS issue_interest_rate
    , CAST(pr_re.first_trading_date AS date) AS first_trading_dt
    , CAST(pr_re.report_year AS int) AS rpt_year
    , CAST(pr_re.report_month AS int) AS rpt_month
    , CAST(pr_re.report_day AS int) AS rpt_day
    , CAST(pr_re.data_dt AS date) AS ds_snpst_dt   -- [FIRST-TIME] cot ds_snpst_dt (macro ft append khong tu them) = ngay nghiep vu ODS
FROM pr_re
