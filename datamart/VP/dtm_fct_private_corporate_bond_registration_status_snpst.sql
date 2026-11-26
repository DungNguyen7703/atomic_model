/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_private_corporate_bond_registration_status_snpst
* Program name: Dtm Fct Private Corporate Bond Registration Status Snapshot
* Created by: huy.pham
* Created date: 2026-11-08
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-18      claude          [O_VP_86] Them par_val (menh gia TP, direct tu nguon).
* 2026-11-08      huy.pham        [MOI, theo LLD O_VP_71]
*                                 Fact snapshot trang thai dang ky giao dich TPDN
*                                 rieng le. Grain = 1 ma TP / 1 trang thai / 1 thang
*                                 bao cao HNX. So lieu LUY KE tu dau nam den cuoi
*                                 thang bao cao. Nguon HNX_REGISTRATION_STATUS_CHANGE.
*                                 snpst_dt_dim_id = etl_date (partition ky thuat).
*                                 cdr_dt_dim_id = LAST_DAY(rpt_year, rpt_month)
*                                 (ngay nghiep vu, JOIN calendar tren CK).
*                                 Filter ds_snpst_dt = etl_date (partition atomic).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(bond_trading_registration_status_id AS string)                                        AS private_corporate_bond_registration_status_snpst_id,
    CAST(date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd') AS string)    AS snpst_dt_dim_id,
    CAST(date_format(LAST_DAY(MAKE_DATE(rpt_year, rpt_month, 1)), 'yyyyMMdd') AS string)       AS cdr_dt_dim_id,
    CAST(bond_code AS string)                                                                  AS bond_code,
    CAST(trading_registration_status AS string)                                                AS trading_registration_status_nm,
    CAST(registered_trading_bond_quantity AS bigint)                                           AS registered_trading_bond_quantity,
    CAST(src_stm_code AS string)                                                               AS src_stm_code,
    CAST(par_val AS bigint)                                                                    AS par_val
FROM {{ ref('atm_bond_trading_registration_status') }}
WHERE src_stm_code = 'HNX_REGISTRATION_STATUS_CHANGE'
    -- [daily]AND ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
