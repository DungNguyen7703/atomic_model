/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_government_bond_bidding_result_snpst
* Program name: Dtm Fct Government Bond Bidding Result Snapshot
* Created by: huy.pham
* Created date: 2026-11-03
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-03      huy.pham           [MOI, theo LLD DTM_VP_fct_government_bond_bidding_result_snpst]
*                                 Fact ket qua dau thau phat hanh trai phieu Chinh phu.
*                                 Grain = 1 dong ket qua dau thau (gov_bond_bidding_result_id).
*                                 Nguon HNX_GOV_BOND_OFFERING, du lieu keo theo thang.
*                                 ETL nap du lich su (upsert theo PK), khong loc daily.
*                                 snpst_dt_dim_id = etl_date (ds_snpst_dt # issue_dt vi
*                                 job chay cuoi thang). cdr_dt_dim_id = issue_dt.
*                                 issue_term_years: quy doi tu bond_term string
*                                 (tuan / 52, thang / 12, nam giu nguyen — O_VP_49).
* 2026-11-09      huy.pham        [SUA, TKNB Nhom 5 HNX06] Them calling_val, rpt_year,
*                                 rpt_month (tu Atomic). Them government_bond_term_dim_id:
*                                 LOOKUP dtm_government_bond_term_dim ON bond_term.
*--------------------------------------------------------------------*
*/

SELECT
    -- PK: lay thang tu Atomic (da hash san)
    CAST(gbr.gov_bond_bidding_result_id                                                    AS string)         AS government_bond_bidding_result_snpst_id,

    -- snpst_dt_dim_id = etl_date (ngay chay job, ds_snpst_dt # issue_dt vi job chay cuoi thang)
    CAST(date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')           AS string)         AS snpst_dt_dim_id,

    -- cdr_dt_dim_id = issue_dt (ngay phat hanh, dung cho calendar JOIN ben flat layer)
    CAST(date_format(gbr.issue_dt, 'yyyyMMdd')                                             AS string)         AS cdr_dt_dim_id,

    CAST(gbr.bidding_session               AS string)              AS bidding_session,
    CAST(gbr.bond_code                     AS string)              AS bond_code,
    CAST(gbr.bond_term                     AS string)              AS bond_term,

    -- issue_term_years: quy doi ky han nguyen van — so nam
    CAST(
        CASE
            WHEN LOWER(gbr.bond_term) LIKE '%tuần%'
                THEN CAST(regexp_extract(gbr.bond_term, '[0-9]+', 0) AS decimal(10,4)) / 52.0
            WHEN LOWER(gbr.bond_term) LIKE '%tháng%'
                THEN CAST(regexp_extract(gbr.bond_term, '[0-9]+', 0) AS decimal(10,4)) / 12.0
            ELSE
                CAST(regexp_extract(gbr.bond_term, '[0-9]+', 0) AS decimal(10,4))
        END
    AS decimal(10,4))                                              AS issue_term_years,

    CAST(gbr.winning_val                   AS decimal(23,2))       AS winning_val,
    CAST(gbr.winning_interest_rate         AS decimal(5,2))        AS winning_interest_rate,
    CAST(gbr.calling_val                   AS decimal(23,2))       AS calling_val,
    CAST(gbr.rpt_year                      AS int)                 AS rpt_year,
    CAST(gbr.rpt_month                     AS int)                 AS rpt_month,
    CAST(gbt.government_bond_term_dim_id   AS string)              AS government_bond_term_dim_id,
    CAST(gbr.src_stm_code                  AS string)              AS src_stm_code

FROM {{ ref('atm_gov_bond_bidding_result') }} gbr
LEFT JOIN uat_dtm.government_bond_term_dim_hstr gbt
    ON  gbt.bond_term = gbr.bond_term
    and gbt.ds_snpst_dt =  to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    and gbt.ds_rcrd_st  = 'ACTIVE'
WHERE gbr.src_stm_code = 'HNX_GOV_BOND_OFFERING'
    -- [DAILY] AND gbr.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
