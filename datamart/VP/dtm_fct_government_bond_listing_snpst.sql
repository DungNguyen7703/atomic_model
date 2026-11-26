/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_government_bond_listing_snpst
* Program name: Fact Government Bond Listing Snapshot
* Created by: huy.pham
* Created date: 2026-11-05
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-05      huy.pham        [MOI, theo LLD] Fact snapshot danh sach TPCP niem
*                                 yet theo thang bao cao HNX. Grain = 1 ma TPCP x 1
*                                 thang bao cao. PK hash(bond_code|rpt_year|rpt_month|
*                                 src_stm_code). snpst_dt = LAST_DAY(rpt_year, rpt_month).
*                                 listed_bond_val = listed_bond_quantity * 100000 (menh
*                                 gia TPCP 100.000 VND/don vi, tinh o ETL).
*                                 Filter = :etl_date (chi nap thang hien tai, job chay
*                                 vao ngay cuoi thang).
*                                 LUU Y: rpt_year / rpt_month duoc them vao
*                                 atm_gov_bond_listing ngay 2026-11-04 (O_VP_62);
*                                 job nay yeu cau atomic da deploy ban moi.
*--------------------------------------------------------------------*
*/

WITH gbl AS (
    SELECT
        bond_code,
        rpt_year,
        rpt_month,
        listed_bond_quantity,
        src_stm_code
    FROM {{ ref('atm_gov_bond_listing') }}
    WHERE src_stm_code = 'HNX_GOV_BOND_LISTED_LIST'
        --AND ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        -- tần suất cập nhật = 1 tháng nên lên lọc dựa trên ds_snpst_dt
)

SELECT
    CAST({{ generate_surrogate_key(
        'HNX_GOV_BOND_LISTED_LIST',
        "CONCAT(bond_code, '|', CAST(rpt_year AS string), '|', CAST(rpt_month AS string), '|', src_stm_code)"
    ) }} AS string)                                                                        AS government_bond_listing_snpst_id,
    CAST(date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd') AS string)  AS snpst_dt_dim_id,
    CAST(date_format(LAST_DAY(MAKE_DATE(rpt_year, rpt_month, 1)), 'yyyyMMdd') AS string)   AS cdr_dt_dim_id,
    CAST(bond_code AS string)                                                              AS bond_code,
    CAST(rpt_year AS int)                                                                  AS rpt_year,
    CAST(rpt_month AS int)                                                                 AS rpt_month,
    CAST(listed_bond_quantity AS bigint)                                                   AS listed_bond_quantity,
    CAST(listed_bond_quantity * 100000 AS decimal(23, 2))                                  AS listed_bond_val,
    CAST(src_stm_code AS string)                                                           AS src_stm_code
FROM gbl
