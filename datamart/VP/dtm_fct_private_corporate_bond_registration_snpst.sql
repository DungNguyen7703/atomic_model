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
*--------------------------------------------------------------------*
*/

WITH reg AS (
    SELECT
        src_stm_code,
        bond_code,
        CAST(rpt_year AS string)                                                           AS rpt_year,
        CAST(rpt_month AS string)                                                          AS rpt_month,
        CAST(maturity_dt AS date)                                                          AS maturity_dt,
        LAST_DAY(MAKE_DATE(CAST(rpt_year AS int), CAST(rpt_month AS int), 1))             AS snpst_dt
    FROM {{ ref('atm_private_corp_bond_registration') }}
    WHERE src_stm_code = 'HNX_PRIVATE_CORP_BOND_REGISTRATION'
        AND LAST_DAY(MAKE_DATE(CAST(rpt_year AS int), CAST(rpt_month AS int), 1))
            = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    CAST({{ generate_surrogate_key_bigint('HNX_PRIVATE_CORP_BOND_REGISTRATION', "CONCAT(bond_code, '|', rpt_year, '|', rpt_month, '|', src_stm_code)") }} AS string) AS private_corporate_bond_registration_snpst_id,
    CAST(date_format(snpst_dt, 'yyyyMMdd') AS string)   AS snpst_dt_dim_id,
    CAST(bond_code AS string)                            AS bond_code,
    CAST(rpt_year AS string)                             AS rpt_year,
    CAST(rpt_month AS string)                            AS rpt_month,
    CAST(maturity_dt AS date)                            AS maturity_dt,
    CAST(src_stm_code AS string)                         AS src_stm_code
FROM reg
