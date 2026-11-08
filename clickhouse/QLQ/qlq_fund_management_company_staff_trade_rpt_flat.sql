-- ────────────────────────────────────────────────────────────
-- Model : qlq_fund_management_company_staff_trade_rpt_flat
-- Type  : OPERATIONAL
-- 2026-10-14 claude: khởi tạo từ flat-table/QLQ/02_populate_qlq_flat_tables.sql #19 (commit d18cdaa0).
--                    Mart dtm_fund_management_company_staff_trade_rpt là append theo trade_dt (không có _hstr).
--                    ck_snapshot: job lọc trade_dt = etl_date nên ds_snpst_dt (= etl_date) = trade_dt.
-- 2026-10-15 claude (sync): đồng bộ flat-table/QLQ/01_create_qlq_flat_tables.sql (commit aea21863) — bỏ cột
--                    securities_trade_code, board_tp_code; sắp lại thứ tự cột theo grain 6 cột của LLD.
--                    INSERT theo vị trí => bảng CK phải ALTER cùng thứ tự (DROP 2 cột + MODIFY ... AFTER).
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Fund Management Company Staff Trade Report
    fmc_employee_code,
    trade_dt,
    securities_account_nbr,
    trade_direction_code,
    security_symbol_code,
    trade_method_nm,
    fmc_code,
    identification_nbr,
    securities_company_code,
    trade_direction_nm,
    order_vol,
    order_price,
    order_amt,
    src_stm_code

FROM {{ ref('dtm_fund_management_company_staff_trade_rpt') }}
-- WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
