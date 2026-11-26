/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_private_corporate_bond_offering_snpst
* Program name: Dtm Fct Private Corporate Bond Offering Snapshot
* Created by: huy.pham
* Created date: 2026-11-11
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-16      claude          [O_VP_83] Them 5 cot: enterprise_tp, business_sector,
*                                 convertible_bond_ind, warrant_linked_bond_ind,
*                                 secured_bond_ind tu atomic.
* 2026-11-11      huy.pham        [MOI, O_VP_76] Fact snapshot tinh hinh chao ban TPDNRL.
*                                 Grain = 1 ma TPDN rieng le x thi truong x ngay dang tin x
*                                 1 thang bao cao HNX (BM 27/28). So lieu nguon la LUY KE
*                                 tu dau nam den cuoi thang bao cao.
*                                 Nap moi thang 1 lan vao ngay cuoi thang bao cao
*                                 (LAST_DAY(MAKE_DATE(rpt_year, rpt_month, 1)) = etl_date).
*                                 DENSE_RANK ds_snpst_dt DESC lay ban nop moi nhat cua thang.
*                                 PK Dang B: sha2(cdr_dt_dim_id|bond_code|market_tp|
*                                 posting_dt|src_stm_code, 256).
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY rpt_year, rpt_month
            ORDER BY ds_snpst_dt DESC
        ) AS rk
    FROM {{ ref('atm_private_corp_bond_offering') }}
    WHERE src_stm_code = 'HNX_PRIVATE_CORP_BOND_OFFERING'
    AND ds_snpst_dt = to_date('2026-10-30', 'yyyy-MM-dd') --chỗ này là do atomic đang có 1 ds_snpst_dt dump nên phải lấy cái đúng
        --AND last_day(make_date(rpt_year, rpt_month, 1)) = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    CAST(
        sha2(concat_ws('|',
            date_format(last_day(make_date(s.rpt_year, s.rpt_month, 1)), 'yyyyMMdd'),
            s.bond_code,
            COALESCE(s.market_tp,              ''),
            COALESCE(CAST(s.posting_dt AS string), ''),
            s.src_stm_code
        ), 256)
    AS string)                                      AS private_corporate_bond_offering_snpst_id,

    CAST(cdr.cdr_dt_dim_id          AS string)      AS cdr_dt_dim_id,
    CAST(s.bond_code                AS string)      AS bond_code,
    CAST(s.market_tp                AS string)      AS market_tp,
    CAST(s.posting_dt               AS date)        AS posting_dt,
    CAST(s.issue_dt                 AS date)        AS issue_dt,
    CAST(s.offering_bond_quantity   AS bigint)      AS offering_bond_quantity,
    CAST(s.par_val                  AS decimal(23,2)) AS par_val,
    CAST(s.offering_bond_quantity * s.par_val AS decimal(23,2)) AS offering_val_amt,
    CAST(s.rpt_year                 AS int)         AS rpt_year,
    CAST(s.rpt_month                AS int)         AS rpt_month,
    CAST(s.rpt_day                  AS int)         AS rpt_day,
    CAST(
        CASE TRIM(s.bond_term_unit)
            WHEN 'Tháng' THEN s.bond_term / 12.0
            WHEN 'Năm'   THEN s.bond_term
        END
    AS decimal(10,4))                               AS bond_term_years,
    CAST(s.issue_interest_rate      AS decimal(5,2)) AS issue_interest_rate,
    CAST(s.enterprise_tp            AS string)      AS enterprise_tp,
    CAST(s.business_sector          AS string)      AS business_sector,
    CAST(s.convertible_bond_ind     AS int)         AS convertible_bond_ind,
    CAST(s.warrant_linked_bond_ind  AS int)         AS warrant_linked_bond_ind,
    CAST(s.secured_bond_ind         AS int)         AS secured_bond_ind,
    CAST(s.src_stm_code             AS string)      AS src_stm_code

FROM src s
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cdr
    ON  cdr.cdr_dt = last_day(make_date(s.rpt_year, s.rpt_month, 1))
WHERE s.rk = 1
