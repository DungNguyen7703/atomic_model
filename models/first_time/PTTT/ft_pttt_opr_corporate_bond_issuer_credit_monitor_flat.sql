-- [FIRST-TIME] ft_pttt_opr_corporate_bond_issuer_credit_monitor_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily pttt_opr_corporate_bond_issuer_credit_monitor_flat (config ft_target='pttt_opr_corporate_bond_issuer_credit_monitor_flat', macro macros/first_time).
-- 2026-10-28 tuan.nguyenvanb: [FIRST-TIME PTTT] Ban khoi tao: doc _hstr ACTIVE cua mart ft (moi ngay 1 snapshot) thay cho bang MAIN loc snpst_dt = etl_date;
-- 2026-11-06 tuan.nguyenvanb: them cot financial_period_end_dt sau roe_pct (ALTER ADD COLUMN AFTER roe_pct).
-- ft_ck_by_day gan partition ds_snpst_dt = ngay snapshot (ft_day_column = ds_snpst_dt) -> 1 partition = 1 ngay nhu daily. Giu dung 15 cot nhu daily + ds_snpst_dt cuoi.

SELECT
    f.issuer_symbol_code,
    f.snpst_dt,
    f.bond_outstanding_val,
    f.par_val,
    f.outstanding_vol,
    f.audit_opinion_text,
    f.ranking_code,
    f.risk_rating_text,
    f.total_liabilities_amt,
    f.owner_equity_ending_amt,
    f.owner_equity_beginning_amt,
    f.owner_equity_average_amt,
    f.net_profit_after_tax_amt,
    f.debt_to_equity_ratio,
    f.roe_pct,
    f.financial_period_end_dt,
    f.ds_snpst_dt   -- [BACKFILL-UAT-NEW] ngay snapshot (ft_ck_by_day, ft_day_column=ds_snpst_dt)
FROM {{ ft_ref('ft_dtm_opr_corporate_bond_issuer_credit_monitor') }}_hstr f   -- [BACKFILL-UAT-NEW] _hstr tung ngay
WHERE f.ds_rcrd_st = 'ACTIVE'
-- [BACKFILL-UAT-ORIG] FROM dtm_opr_corporate_bond_issuer_credit_monitor f WHERE f.snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
