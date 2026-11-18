-- [FIRST-TIME] ft_dtm_fct_corporate_bond_sector_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_corporate_bond_sector_snpst (config ft_target='fct_corporate_bond_sector_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_corporate_bond_sector_snpst
* Program name: Fact Corporate Bond Sector Snapshot (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_corporate_bond_sector_snpst:
*									- doc atomic qua ft_ref (ft_atm_security_trading_snapshot / ft_atm_listed_share_information), BO loc theo etl_date.
*									- append: ds_snpst_dt = trading_dt cua tung dong, dat CUOI SELECT.
*									- Dedupe ban tin cuoi theo (ma, ngay); lsi_hnx noi theo ds_snpst_dt = trading_dt; mkt_total gom theo trading_dt.
*									- GIOI HAN: atm_public_company (scd4a) doc bang MAIN ds_rcrd_st='ACTIVE' (khong doc _hstr theo ngay) -> nganh cua TCPH la gia tri HIEN TAI
*									  cho moi ngay lich su (thuoc tinh danh muc, khong co lich su theo ngay).
*--------------------------------------------------------------------*
* 2026-11-09		tuan.nguyenvanb		[DOI TEN COT ATOMIC public_company theo design 2026-11-08] doc cl_ids_business_line_level_1_id/code, exchange_code, pc_form_tp_code (ten cu business_line_level_1_id/code,
*                                       equity_listing_exchange_code, pc_form_code) va giu alias ten cu o CTE nen phan con lai khong doi. Khong doi cot/kieu mart.
* 2026-11-11		tuan.nguyenvanb		[BA/DEV CHOT PHUONG AN 2] Dong bo daily: them dong 'chua phan nganh' (corp_bond_industry_dim_id NULL) cho TP khong ghep duoc nganh; LEFT JOIN pu_co, dedupe pu_co 1 dong/ticker. Khong doi cot.
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)

WITH bond_raw AS (
    SELECT
        ticker_symbol AS symbol
        , ds_snpst_dt AS trading_dt
        , trading_time
        , sequence
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE stock_tp_code = '1'
        AND NOT (
            ticker_symbol RLIKE '^[A-Za-z]{2}GB'
            OR ticker_symbol RLIKE '^(TD|TP|CP|QH|KB|BL)'
            OR ticker_symbol RLIKE '^(HCM|HAN)'
        )
),

bond_snpst AS (
    SELECT
        symbol
        , trading_dt
    FROM (
        SELECT
            bond_raw.*
            , ROW_NUMBER() OVER (
                PARTITION BY bond_raw.symbol, bond_raw.trading_dt   -- [BACKFILL-UAT-NEW] them khoa ngay
                ORDER BY bond_raw.trading_time DESC, bond_raw.sequence DESC
            ) AS rn
        FROM bond_raw
    ) ranked
    WHERE rn = 1
),

lsi_hnx AS (
    SELECT
        ticker_symbol
        , ds_snpst_dt
        , listed_share_quantity
    FROM {{ ft_ref('ft_atm_listed_share_information') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE src_stm_code = 'HNX_LISTED_SECURITIES_LIST'
    -- [BACKFILL-UAT-ORIG]     AND ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

bond_vol AS (
    SELECT
        bond_snpst.symbol
        , bond_snpst.trading_dt
        , lsi_hnx.listed_share_quantity
    FROM bond_snpst
    INNER JOIN lsi_hnx
        ON lsi_hnx.ticker_symbol = bond_snpst.symbol   -- [FIX 2026-10-28] ma trai phieu day du (khong SUBSTR 3 ky tu: khop nham dong co phieu cung TCPH)
        AND lsi_hnx.ds_snpst_dt = bond_snpst.trading_dt
),

pu_co_all AS (
    SELECT
        cl_ids_business_line_level_1_code AS business_line_level_1_code
        , equity_ticker_symbol
        -- 1 dong / ticker (nguon IDS co ticker gan >1 pc_id cung ACTIVE) - order theo id nguon that (pc_code), KHONG theo pc_id hash
        , ROW_NUMBER() OVER (PARTITION BY equity_ticker_symbol ORDER BY CAST(pc_code AS bigint) ASC) AS rn
    FROM {{ ref('atm_public_company') }}   -- [BACKFILL-UAT-NEW] bang MAIN (thay _hstr theo ngay)
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_public_company') }}_hstr ... WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_ticker_symbol IS NOT NULL
        AND pc_code IS NOT NULL
),

pu_co AS (
    SELECT business_line_level_1_code, equity_ticker_symbol
    FROM pu_co_all
    WHERE rn = 1
),

-- [2026-11-11] LEFT JOIN: TP khong ghep duoc cong ty dai chung / cong ty khong co ma nganh / ma nganh khong co trong dim
-- duoc gom vao 1 dong 'chua phan nganh' (industry_code NULL -> corp_bond_industry_dim_id NULL) -> tong ty trong cac dong = 100%.
joined AS (
    SELECT
        bond_vol.trading_dt
        , cbi.industry_code AS business_line_level_1_code   -- NULL neu khong ghep duoc nganh trong dim
        , bond_vol.listed_share_quantity
    FROM bond_vol
    LEFT JOIN pu_co
        ON pu_co.equity_ticker_symbol = SUBSTR(bond_vol.symbol, 1, 3)
    LEFT JOIN {{ ref('dtm_corp_bond_industry_dim') }} cbi
        ON cbi.industry_code = pu_co.business_line_level_1_code
        AND cbi.ds_rcrd_st = 'ACTIVE'
        AND cbi.src_stm_code = 'IDS_CATEGORIES'
),

agg AS (
    SELECT
        joined.trading_dt
        , joined.business_line_level_1_code
        , SUM(100000 * joined.listed_share_quantity) AS bond_outstanding_val
    FROM joined
    GROUP BY
        joined.trading_dt
        , joined.business_line_level_1_code
),

mkt_total AS (
    SELECT
        bond_vol.trading_dt
        , SUM(100000 * bond_vol.listed_share_quantity) AS bond_outstanding_val_total
    FROM bond_vol
    GROUP BY bond_vol.trading_dt
),

enriched AS (
    SELECT
        CAST(date_format(agg.trading_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
        CAST(cbi.corp_bond_industry_dim_id AS string)           AS corp_bond_industry_dim_id,
        CAST(agg.bond_outstanding_val AS decimal(23,2))         AS bond_outstanding_val,
        agg.trading_dt
    FROM agg
    LEFT JOIN {{ ref('dtm_corp_bond_industry_dim') }} cbi
        ON cbi.industry_code = agg.business_line_level_1_code
        AND cbi.ds_rcrd_st = 'ACTIVE'
        AND cbi.src_stm_code = 'IDS_CATEGORIES'  -- [2026-10-29] loc src_stm_code: bang dim scd4a chi so sanh/ngung hieu luc ban ghi thuoc source_system IDS_CATEGORIES -> ban ghi cu tu nguon khac (truoc 2026-10-23) van ACTIVE, khong loc se nhan dong
)

SELECT
    enriched.snpst_dt_dim_id,
    enriched.corp_bond_industry_dim_id,
    enriched.bond_outstanding_val,
    CAST(mkt_total.bond_outstanding_val_total AS decimal(23,2)) AS bond_outstanding_val_total,
    CAST(
        enriched.bond_outstanding_val
        / NULLIF(mkt_total.bond_outstanding_val_total, 0)
        * 100
    AS decimal(5,2)) AS bond_outstanding_ratio,
    CAST(enriched.trading_dt AS date) AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = ngay giao dich (daily: = etl_date)
FROM enriched
LEFT JOIN mkt_total
    ON mkt_total.trading_dt = enriched.trading_dt
