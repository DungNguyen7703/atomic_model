-- [FIRST-TIME] ft_dtm_security_trading_snpst_dim: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_security_trading_snpst_dim (config ft_target='security_trading_snpst_dim', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_security_trading_snpst_dim
* Program name: Dtm Security Trading Snpst Dim
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-26		tuan.nguyenvanb		bo sung cot stock_tp_nm theo LLD
* 2026-09-16		tuan.nguyenvanb		[FIX] stock_tp_nm sai/thieu so voi logic
*                                       phan loai ma CK chuan (doi chieu cau test
*                                       cua BA): thieu han floor_code='04' (UPCOM -
*                                       luon roi ELSE 'Khong xac dinh'); HOSE
*                                       stock_tp_code=3 chua tach ETF (fund_tp_code=
*                                       'E') voi Chung chi quy (fund_tp_code='M');
*                                       HNX/UPCOM thieu stock_tp_code=4 (Phai sinh)
*                                       va gop nham stock_tp_code=6 (ETF) vao chung
*                                       voi 5 (Chung quyen). Sua lai dung theo cau
*                                       truc floor_code='10' rieng, floor_code IN
*                                       ('02','04') rieng nhu logic test.
* 2026-09-22		tuan.nguyenvanb		[MOI, LLD bo sung gap STT 23] Them 2 cot
*                                       ceiling_price (Gia tran)/floor_price (Gia
*                                       san) - direct tu atm_security_trading_snapshot,
*                                       cung pattern voi open_price/high_price/...
*                                       da co san.
* 2026-09-30		tuan.nguyenvanb		[SUA theo LLD 2026-09-30, BA GSTT dong 9] stock_tp_nm
*                                       tra ve MA (TRAI_PHIEU/CO_PHIEU/ETF/CHUNG_CHI_QUY/
*                                       CHUNG_QUYEN/PHAI_SINH/KHAC) thay cho nhan tieng Viet
*                                       ('Trai phieu'/'Co phieu'/.../'Khong xac dinh'). Khong
*                                       doi cot/kieu du lieu - chi doi gia tri, khong can ALTER.
* 2026-10-08		tuan.nguyenvanb		[SUA theo LLD 2026-10-08, BA GSTT cap nhat CASE, O_GSTT_61] stock_tp_nm tra ve NHAN TIENG VIET
*                                       (Trai phieu/Co phieu/ETF/Chung chi quy/Chung quyen/Phai sinh/Khac) thay cho nhan ma
*                                       TRAI_PHIEU/CO_PHIEU/... cua BA 2026-09-30. Cau truc CASE khong doi. Khong doi cot/kieu
*                                       du lieu - chi doi gia tri, khong can ALTER.
* 2026-10-17		tuan.nguyenvanb		[FIRST-TIME] ft_hstr_by_day: snapshot TUNG NGAY (1 ban ghi/ma/ngay, bo loc etl_date), them cot ds_snpst_dt cuoi.
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu snapshot.symbol->ticker_symbol, security_full_nm->full_nm. Khong doi cot/kieu.
*--------------------------------------------------------------------*
*/

WITH se_tr_sn_all AS (
    SELECT
        ticker_symbol AS symbol,
        full_nm AS security_full_nm,
        floor_code,
        stock_tp_code,
        underlying_symbol,
        isin_code,
        issuer_nm,
        listed_share_count,
        first_trading_dt,
        last_trading_dt,
        issue_dt,
        maturity_dt,
        fund_tp_code,
        covered_warrant_tp_code,
        exercise_price,
        exercise_ratio,
        exercise_style_code,
        put_or_call_code,
        contract_multiplier,
        maturity_month_year,
        coupon_rate,
        yield,
        open_price,
        high_price,
        low_price,
        ceiling_price,
        floor_price,
        reference_price,
        close_price,
        price_change,
        product_group_id,
        src_stm_code,
        trading_time,
        ds_snpst_dt,
        row_number() over (partition by ticker_symbol, ds_snpst_dt order by trading_time desc, sequence desc) as rn   -- [FIRST-TIME 2026-10-17] 1 ban ghi / ma / NGAY (snapshot tung ngay, giong daily)
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'   -- [FIRST-TIME 2026-10-17] ft_hstr_by_day: lay TOAN BO lich su, khong loc etl_date; moi ngay 1 snapshot
),

se_tr_sn AS (
    SELECT
        symbol,
        security_full_nm,
        floor_code,
        stock_tp_code,
        underlying_symbol,
        isin_code,
        issuer_nm,
        listed_share_count,
        first_trading_dt,
        last_trading_dt,
        issue_dt,
        maturity_dt,
        fund_tp_code,
        covered_warrant_tp_code,
        exercise_price,
        exercise_ratio,
        exercise_style_code,
        put_or_call_code,
        contract_multiplier,
        maturity_month_year,
        coupon_rate,
        yield,
        open_price,
        high_price,
        low_price,
        ceiling_price,
        floor_price,
        reference_price,
        close_price,
        price_change,
        product_group_id,
        src_stm_code,
        ds_snpst_dt
    FROM se_tr_sn_all
    WHERE rn = 1
)

SELECT
    CAST({{ generate_surrogate_key_bigint('MDDS_JAD_STOCKINFOR', 'symbol') }} AS string) AS security_trading_snpst_dim_id,
    CAST(symbol AS string)                                          AS symbol,
    CAST(security_full_nm AS string)                                AS security_full_nm,
    CAST(floor_code AS string)                                      AS floor_code,
    CAST(stock_tp_code AS string)                                   AS stock_tp_code,
    CAST(
        CASE
            WHEN floor_code = '10' THEN
                CASE
                    WHEN stock_tp_code = '1' THEN 'Trái phiếu'
                    WHEN stock_tp_code = '2' THEN 'Cổ phiếu'
                    WHEN stock_tp_code = '3' AND fund_tp_code = 'E' THEN 'ETF'
                    WHEN stock_tp_code = '3' AND fund_tp_code = 'M' THEN 'Chứng chỉ quỹ'
                    WHEN stock_tp_code = '4' THEN 'Chứng quyền'
                    ELSE 'Khác'
                END
            WHEN floor_code IN ('02','04') THEN
                CASE
                    WHEN stock_tp_code = '1' THEN 'Trái phiếu'
                    WHEN stock_tp_code = '2' THEN 'Cổ phiếu'
                    WHEN stock_tp_code = '3' THEN 'Chứng chỉ quỹ'
                    WHEN stock_tp_code = '4' THEN 'Phái sinh'
                    WHEN stock_tp_code = '5' THEN 'Chứng quyền'
                    WHEN stock_tp_code = '6' THEN 'ETF'
                    ELSE 'Khác'
                END
            ELSE 'Khác'
        END
    AS string)                                                      AS stock_tp_nm,
    CAST(underlying_symbol AS string)                               AS underlying_symbol,
    CAST(isin_code AS string)                                       AS isin_code,
    CAST(issuer_nm AS string)                                       AS issuer_nm,
    CAST(listed_share_count AS bigint)                              AS listed_share_count,
    CAST(first_trading_dt AS date)                                  AS first_trading_dt,
    CAST(last_trading_dt AS date)                                   AS last_trading_dt,
    CAST(issue_dt AS date)                                          AS issue_dt,
    CAST(maturity_dt AS date)                                       AS maturity_dt,
    CAST(fund_tp_code AS string)                                    AS fund_tp_code,
    CAST(covered_warrant_tp_code AS string)                         AS covered_warrant_tp_code,
    CAST(exercise_price AS decimal(23,2))                           AS exercise_price,
    CAST(exercise_ratio AS string)                                  AS exercise_ratio,
    CAST(exercise_style_code AS string)                             AS exercise_style_code,
    CAST(put_or_call_code AS string)                                AS put_or_call_code,
    CAST(contract_multiplier AS string)                             AS contract_multiplier,
    CAST(maturity_month_year AS string)                             AS maturity_month_year,
    CAST(coupon_rate AS decimal(8,5))                               AS coupon_rate,   -- [2026-10-13 THEO LLD v4.47] decimal(8,5)
    CAST(yield AS decimal(8,5))                                     AS yield,
    CAST(open_price AS decimal(23,2))                               AS open_price,
    CAST(high_price AS decimal(23,2))                               AS high_price,
    CAST(low_price AS decimal(23,2))                                AS low_price,
    CAST(ceiling_price AS decimal(23,2))                            AS ceiling_price,
    CAST(floor_price AS decimal(23,2))                              AS floor_price,
    CAST(reference_price AS decimal(23,2))                          AS reference_price,
    CAST(close_price AS decimal(23,2))                              AS close_price,
    CAST(price_change AS decimal(23,2))                             AS price_change,
    CAST(product_group_id AS string)                                AS product_group_id,
    CAST(src_stm_code AS string)                                    AS src_stm_code,
    CAST(ds_snpst_dt AS date)                                       AS ds_snpst_dt   -- [FIRST-TIME 2026-10-17] ngay snapshot (ft_hstr_by_day)
FROM se_tr_sn
