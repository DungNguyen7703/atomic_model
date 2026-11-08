-- [FIRST-TIME] ft_dtm_fct_public_company_foreign_ownership_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_public_company_foreign_ownership_snpst (config ft_target='fct_public_company_foreign_ownership_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_public_company_foreign_ownership_snpst
* Program name: Dtm Fct Public Company Foreign Ownership Snpst
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-17		nghia.le			[FIX] snpst_dt_dim_id: dong bo thay doi daily (LOOKUP dtm_cdr_dt_dim thay vi
*									date_format(...,'yyyyMMdd') hard-format) - ban truoc do bi sot khi dong bo tu daily.
* 2026-10-17		nghia.le			[FIRST-TIME NDTNN] Ban khoi tao: doc atomic qua ft_ref('ft_atm_foreign_ownership_info') (GSTT first-time) va BO loc
*                                       ds_snpst_dt = etl_date de nap toan bo lich su trong 1 lan, moi ngay 1 partition snpst_dt_dim_id nhu daily;
*                                       dtm_public_company_dim doc bang MAIN thay vi _hstr tai etl_date.
* 2026-11-03							[THÊM] foreign_holding_value (O_NDTNN_55, K_NDTNN_51 Nhóm 8): dong bo voi
*									daily dtm_fct_public_company_foreign_ownership_snpst - JOIN
*									atm_security_trading_snapshot lay close_price gan nhat <= ngay snapshot cua tung dong.
*
*--------------------------------------------------------------------*
*/

WITH fo_ow AS (
    SELECT
        ticker_symbol,
        total_issued_share_quantity,
        max_foreign_ownership_ratio,
        max_foreign_holding_quantity,
        current_foreign_holding_quantity,
        remaining_foreign_holding_quantity,
        ds_snpst_dt,
        src_stm_code
    -- [FT-ORIG] FROM {{ ref('atm_foreign_ownership_information') }}
    FROM {{ ft_ref('ft_atm_foreign_ownership_info') }}   -- [FT-NEW] bang that da duoc bo first-time GSTT nap lich su
    -- [FT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    --     AND src_stm_code = 'VSDC_FOREIGN_INVESTOR_INFO'
    WHERE src_stm_code = 'VSDC_FOREIGN_INVESTOR_INFO'   -- [FT-NEW] bo loc ngay: nap toan bo lich su, snpst_dt_dim_id = ngay cua tung dong
),

cd_dt_di AS (
    SELECT
        cdr_dt_dim_id,
        cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
),

pu_co_di AS (
    SELECT
        public_company_dim_id,
        equity_ticker_symbol
    -- [FT-ORIG] FROM {{ ref('dtm_public_company_dim') }}_hstr WHERE ds_snpst_dt = etl_date AND ds_rcrd_st = 'ACTIVE'
    -- [FT-NEW 2026-10-26] doc bang MAIN (ACTIVE) cua dtm_public_company_dim, KHONG doc _hstr theo ngay (hstr thua ngay -> join theo ngay ra NULL)
    FROM {{ ref('dtm_public_company_dim') }}
    WHERE ds_rcrd_st = 'ACTIVE'
),

se_tr_sn AS (
    SELECT
        ticker_symbol,
        trading_dt,
        close_price
    FROM
        (SELECT
            ticker_symbol,
            trading_dt,
            close_price,
            row_number() over (
                partition by ticker_symbol, trading_dt
                order by trading_time desc) as rn
        FROM {{ ref('atm_security_trading_snapshot') }}
        )
    WHERE rn = 1
)

SELECT
    CAST(cd_dt_di.cdr_dt_dim_id AS string)                       AS snpst_dt_dim_id,
    CAST(pu_co_di.public_company_dim_id AS string)               AS public_company_dim_id,
    CAST(fo_ow.ticker_symbol AS string)                          AS ticker_symbol,
    CAST(fo_ow.total_issued_share_quantity AS bigint)               AS total_issued_share_quantity,
    CAST(fo_ow.max_foreign_ownership_ratio AS decimal(5,2))      AS max_foreign_ownership_ratio,
    CAST(fo_ow.max_foreign_holding_quantity AS bigint)              AS max_foreign_holding_quantity,
    CAST(fo_ow.current_foreign_holding_quantity AS bigint)          AS current_foreign_holding_quantity,
    CAST(fo_ow.remaining_foreign_holding_quantity AS bigint)        AS remaining_foreign_holding_quantity,
    CAST(fo_ow.src_stm_code AS string)                           AS src_stm_code,
    CAST(fo_ow.current_foreign_holding_quantity * se_tr_sn_lst.close_price AS decimal(23,2))
                                                                  AS foreign_holding_value
FROM fo_ow
LEFT JOIN cd_dt_di
    ON  cd_dt_di.cdr_dt = fo_ow.ds_snpst_dt
LEFT JOIN pu_co_di
    ON  pu_co_di.equity_ticker_symbol = fo_ow.ticker_symbol
LEFT JOIN se_tr_sn se_tr_sn_lst
    ON  se_tr_sn_lst.ticker_symbol = fo_ow.ticker_symbol
    AND se_tr_sn_lst.trading_dt = (
        SELECT MAX(t2.trading_dt)
        FROM se_tr_sn t2
        WHERE t2.ticker_symbol = fo_ow.ticker_symbol
            AND t2.trading_dt <= fo_ow.ds_snpst_dt
    )
