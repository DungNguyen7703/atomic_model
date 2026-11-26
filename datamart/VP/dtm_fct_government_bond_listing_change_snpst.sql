/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_government_bond_listing_change_snpst
* Program name: Dtm Fct Government Bond Listing Change Snapshot
* Created by: huy.pham
* Created date: 2026-11-08
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-18      claude          [O_VP_86] Them cot par_val (menh gia TPCP).
* 2026-11-08      huy.pham        [MOI, theo LLD O_VP_71]
*                                 Fact snapshot thay doi niem yet TPCP tren HNX.
*                                 Grain = 1 su kien / 1 ma TPCP / listing_change_dt.
*                                 Nguon HNX_GOV_BOND_ADDITIONAL_LISTING.
*                                 snpst_dt_dim_id = etl_date (partition ky thuat).
*                                 cdr_dt_dim_id = listing_change_dt (ngay nghiep vu).
*                                 Filter ds_snpst_dt = etl_date (partition atomic).
*                                 listing_status giu nguyen nhan nguon ('Niem yet moi',
*                                 'Niem yet bo sung', 'Dao han').
*--------------------------------------------------------------------*
*/

SELECT
    CAST(additional_gov_bond_listing_id AS string)                                             AS government_bond_listing_change_snpst_id,
    CAST(date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd') AS string)    AS snpst_dt_dim_id,
    CAST(date_format(listing_change_dt, 'yyyyMMdd') AS string)                                 AS cdr_dt_dim_id,
    CAST(bond_code AS string)                                                                  AS bond_code,
    CAST(listing_status AS string)                                                             AS listing_status_nm,
    CAST(additional_bond_vol AS bigint)                                                        AS additional_bond_quantity,
    CAST(par_val AS bigint)                                                                    AS par_val,
    CAST(src_stm_code AS string)                                                               AS src_stm_code
FROM {{ ref('atm_additional_gov_bond_listing') }}
WHERE src_stm_code = 'HNX_GOV_BOND_ADDITIONAL_LISTING'
    --AND ds_snpst_dt= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
