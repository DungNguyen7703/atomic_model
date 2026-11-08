/*
*--------------------------------------------------------------------*
* Program code: dtm_security_trading_snpst_dim
* Program name: Dtm Security Trading Snpst Dim
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
* 2026-11-04						[MOI theo LLD] Them cot product_group_id (direct tu atm_security_trading_snapshot), truoc src_stm_code.
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
        row_number() over (partition by ticker_symbol order by ds_snpst_dt desc, trading_time desc, sequence desc) as rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')   -- [2026-10-14 THEO LLD] chi ngay etl_date (huy ban 'moi nhat toan lich su' 2026-10-13)
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
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
        src_stm_code
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
    CAST(coupon_rate AS decimal(8,5))                               AS coupon_rate,   -- [2026-10-13 THEO LLD v4.47] decimal(8,5) (truoc day 18,5 theo BA 2026-10-10)
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
    CAST(src_stm_code AS string)                                    AS src_stm_code
FROM se_tr_sn
