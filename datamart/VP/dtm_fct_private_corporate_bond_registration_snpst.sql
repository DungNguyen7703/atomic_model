/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_private_corporate_bond_registration_snpst
* Program name: Dtm Fct Private Corporate Bond Registration Snapshot
* Created by: huy.pham
* Created date: 2026-10-28
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-10-28      huy.pham        [MOI, theo LLD DTM_VP_fct_private_corporate_bond_
*                                 registration_snpst.csv] Fact factless danh sach TPDN rieg
*                                 le dang ky GD theo thang bao cao HNX. Grain = 1 ma TP x
*                                 1 thang bao cao. Khong co measure. Chi nap khi :etl_date
*                                 = ngay cuoi thang bao cao (LAST_DAY suy ra tu rpt_year/
*                                 rpt_month — O_VP_27). O_VP_26: khoa atomic chi bam bond_
*                                 code, lich su thang co the bi ghi de, nap theo etl_date
*                                 de giu dung snapshot thang.
* 2026-10-29      huy.pham        Them src_stm_code vao PK hash va SELECT de tranh trung
*                                 khoa khi nhieu nguon.
* 2026-11-07      huy.pham        [FULL HISTORY] Mo rong filter LAST_DAY tu = etl_date
*                                 thanh <= etl_date de nap toan bo lich su cac thang.
*                                 snpst_dt_dim_id = etl_date (partition ky thuat);
*                                 rpt_dt_dim_id = LAST_DAY(rpt_year/rpt_month) (ngay cuoi
*                                 thang bao cao, dung cho calendar JOIN ben flat layer).
* 2026-11-09      huy.pham        [SUA, O_VP_68] Them 3 cot measure: registered_trading_
*                                 bond_quantity, par_val (tu nguon), registered_trading_val
*                                 = KL * par_val (computed).
* 2026-11-16      claude          [O_VP_81] Them 2 cot: outstanding_bond_quantity (bigint),
*                                 remaining_bond_term (int) tu atomic.
*--------------------------------------------------------------------*
*/

WITH reg AS (
    SELECT
        src_stm_code,
        bond_code,
        CAST(rpt_year AS string)                                                           AS rpt_year,
        CAST(rpt_month AS string)                                                          AS rpt_month,
        CAST(maturity_dt AS date)                                                          AS maturity_dt,
        CAST(registered_trading_bond_quantity AS bigint)                                   AS registered_trading_bond_quantity,
        CAST(par_val AS bigint)                                                            AS par_val,
        CAST(outstanding_bond_quantity AS bigint)                                          AS outstanding_bond_quantity,
        CAST(remaining_bond_term AS int)                                                   AS remaining_bond_term,
        LAST_DAY(MAKE_DATE(CAST(rpt_year AS int), CAST(rpt_month AS int), 1))             AS snpst_dt
    FROM {{ ref('atm_private_corp_bond_registration') }}
    WHERE src_stm_code = 'HNX_PRIVATE_CORP_BOND_REGISTRATION'
    --and ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        --AND LAST_DAY(MAKE_DATE(CAST(rpt_year AS int), CAST(rpt_month AS int), 1))
            --<= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')  -- [DAILY] doi <= thanh =
)

SELECT
    CAST({{ generate_surrogate_key_bigint('HNX_PRIVATE_CORP_BOND_REGISTRATION', "CONCAT(bond_code, '|', rpt_year, '|', rpt_month, '|', src_stm_code)") }} AS string) AS private_corporate_bond_registration_snpst_id,
    CAST(date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(date_format(snpst_dt, 'yyyyMMdd') AS string)   AS rpt_dt_dim_id,
    CAST(bond_code AS string)                            AS bond_code,
    CAST(rpt_year AS string)                             AS rpt_year,
    CAST(rpt_month AS string)                            AS rpt_month,
    CAST(maturity_dt AS date)                            AS maturity_dt,
    CAST(registered_trading_bond_quantity AS bigint)     AS registered_trading_bond_quantity,
    CAST(par_val AS bigint)                              AS par_val,
    CAST(registered_trading_bond_quantity * par_val AS decimal(23, 2))
                                                         AS registered_trading_val,
    CAST(outstanding_bond_quantity AS bigint)             AS outstanding_bond_quantity,
    CAST(remaining_bond_term AS int)                      AS remaining_bond_term,
    CAST(src_stm_code AS string)                         AS src_stm_code
FROM reg
