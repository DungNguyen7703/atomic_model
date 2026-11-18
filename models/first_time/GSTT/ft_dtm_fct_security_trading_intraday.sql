-- [FIRST-TIME] ft_dtm_fct_security_trading_intraday: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_security_trading_intraday (config ft_target='fct_security_trading_intraday', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_security_trading_intraday
* Program name: Dtm Fct Security Trading Intraday
* Created by: tuan.nguyenvanb
* Created date: 2026-08-26
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-26		tuan.nguyenvanb		tao moi model theo LLD DTM_GSTT_fct_security_trading_intraday
* 2026-09-04		tuan.nguyenvanb		atm_security_trading_snapshot da co cot trading_tms
*                                       that (khong con phai tu noi trading_dt+trading_time
*                                       bang to_timestamp/concat nua) - doi sang dung truc
*                                       tiep cot trading_tms tu atomic theo dung LLD.
* 2026-09-09		tuan.nguyenvanb		[SUA theo LLD 2026-09-07] Doi han nguon tu
*                                       atm_security_trading_snapshot (snapshot cuoi ngay,
*                                       1 dong/ma CK/ngay) sang atm_market_price_snapshot
*                                       (nen 1-phut, src_stm_code=MDDS_JAD_TRADINGVIEWHISTORY1MIN)
*                                       - dung dung "intraday" nhu ten model. trading_tms
*                                       gio ghep tu trading_dt + processing_time (khong con
*                                       la cot trading_tms cu cua security_trading_snapshot).
*                                       cumulative_vol_at_time phai running-sum lai vi
*                                       market_price_snapshot.vol la KLGD PHAT SINH RIENG
*                                       trong tung phut, khong phai luy ke san. cdr_dt_dim_id
*                                       KHONG join dtm_cdr_dt_dim - format truc tiep tu
*                                       trading_dt (theo quy uoc chung cua GSTT, xem cac mart
*                                       khac vd dtm_fct_stock_portfolio_snpst).
* 2026-10-08		tuan.nguyenvanb		[BACKFILL-UAT-NEW] TAM THOI: doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
*                                       Dong goc duoc giu o dang comment BACKFILL-UAT-ORIG. Chuyen che do daily bang dbt/first_time_mode.py [BACKFILL-UAT-NEW]
*                                       de tra ve nguyen ban sau khi chay xong du lieu 1 nam. [BACKFILL-UAT-NEW]
* 2026-10-18		tuan.nguyenvanb		[FIX dim_id NULL o ma INACTIVE tai dim MAIN] noi dim security_trading_snpst_dim bang _hstr theo NGAY (ds_snpst_dt = ngay giao dich) thay vi MAIN ACTIVE. Khong doi cot.
*--------------------------------------------------------------------*
*/

/*
CAP NHAT 2026-09-09: atm_market_price_snapshot + STG/ODS (stg_mdds_jad_tvhistory1m,
ods_mdds_jad_tvhistory1m) da duoc build (nguon MDDS.JAD_TVHISTORY1M). Model nay het
chan compile.

VAN CON GIA DINH CHUA XAC NHAN (xem chi tiet o stg_mdds_jad_tvhistory1m.sql):
- TRADINGDATE (varchar2) gia dinh dinh dang 'dd/MM/yyyy', chua co mau du lieu that.
- MINUTE (processing_time) gia dinh da la 'HH:mm' san, chua Data Modeler/DBA profile
  lai. Neu sai dinh dang, to_timestamp(concat(...)) ben duoi se loi hoac ra sai gia tri
  - can kiem tra ky khi co du lieu that truoc khi tin dung production.
*/

WITH ma_pr_sn AS (
    SELECT
        symbol,
        trading_dt,
        processing_time,
        open_price,
        high_price,
        low_price,
        close_price,
        vol
    FROM {{ ft_ref('ft_atm_market_price_snapshot') }}
    WHERE 
    -- ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    --     AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    --     AND 
        src_stm_code = 'MDDS_JAD_TVHISTORY1MIN' --chạy 1 năm dữ liệu
),

ma_pr_sn_cum AS (
    SELECT
        symbol,
        trading_dt,
        processing_time,
        open_price,
        high_price,
        low_price,
        close_price,
        -- market_price_snapshot.vol la KLGD phat sinh rieng trong phut (khong phai luy ke) -
        -- phai running-sum lai theo dung ban chat luy ke cua cumulative_vol_at_time (LLD).
        SUM(vol) OVER (PARTITION BY symbol, trading_dt ORDER BY processing_time) AS cumulative_vol_at_time
    FROM ma_pr_sn
),

se_tr_sn_di AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol,
        ds_snpst_dt
    FROM {{ ft_ref('ft_dtm_security_trading_snpst_dim') }}_hstr   -- [FIRST-TIME 2026-10-18] doc _hstr theo NGAY, khong doc MAIN
    WHERE ds_rcrd_st = 'ACTIVE'
)

SELECT
    CAST(se_tr_sn_di.security_trading_snpst_dim_id AS string)                                        AS security_trading_snpst_dim_id,
    CAST(date_format(ma_pr_sn_cum.trading_dt, 'yyyyMMdd') AS string)                                  AS cdr_dt_dim_id,
    to_timestamp(concat(date_format(ma_pr_sn_cum.trading_dt, 'yyyy-MM-dd'), ' ', ma_pr_sn_cum.processing_time)) AS trading_tms,
    CAST(ma_pr_sn_cum.open_price AS decimal(23,2))                                                    AS open_price_at_time,
    CAST(ma_pr_sn_cum.high_price AS decimal(23,2))                                                    AS high_price_at_time,
    CAST(ma_pr_sn_cum.low_price AS decimal(23,2))                                                     AS low_price_at_time,
    CAST(ma_pr_sn_cum.close_price AS decimal(23,2))                                                   AS close_price_at_time,
    CAST(ma_pr_sn_cum.cumulative_vol_at_time AS int)                                                  AS cumulative_vol_at_time
FROM ma_pr_sn_cum
LEFT JOIN se_tr_sn_di
    ON  se_tr_sn_di.symbol = ma_pr_sn_cum.symbol
    AND se_tr_sn_di.ds_snpst_dt = CAST(ma_pr_sn_cum.trading_dt AS date)   -- [FIRST-TIME 2026-10-18]
