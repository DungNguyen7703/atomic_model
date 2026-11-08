/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_public_company_foreign_ownership_snpst
* Program name: Dtm Fct Public Company Foreign Ownership Snpst
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-17		nghia.le			snpst_dt_dim_id: đổi từ date_format(ds_snpst_dt,'yyyyMMdd') hard-format sang
*									LOOKUP dtm_cdr_dt_dim (cdr_dt_dim.cdr_dt = foreign_ownership_info.ds_snpst_dt)
*									đúng etl_logic_type=lookup_date theo LLD.
* 2026-11-03							[THÊM] foreign_holding_value (O_NDTNN_55, K_NDTNN_51 Nhóm 8): JOIN
*									atm_security_trading_snapshot lấy close_price gần nhất <= ngày snapshot,
*									công thức = current_foreign_holding_quantity * close_price, theo LLD
*									(cùng công thức với cột cùng tên ở Fact GSDC foreign_holding_snpst).
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
    FROM {{ ref('atm_foreign_ownership_information') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'VSDC_FOREIGN_INVESTOR_INFO'
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
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
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
        WHERE ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND trading_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
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
    CAST(fo_ow.current_foreign_holding_quantity * se_tr_sn.close_price AS decimal(23,2))
                                                                  AS foreign_holding_value
FROM fo_ow
LEFT JOIN cd_dt_di
    ON  cd_dt_di.cdr_dt = fo_ow.ds_snpst_dt
LEFT JOIN pu_co_di
    ON  pu_co_di.equity_ticker_symbol = fo_ow.ticker_symbol
LEFT JOIN se_tr_sn
    ON  se_tr_sn.ticker_symbol = fo_ow.ticker_symbol
    AND se_tr_sn.trading_dt = (
        SELECT MAX(t2.trading_dt)
        FROM se_tr_sn t2
        WHERE t2.ticker_symbol = fo_ow.ticker_symbol
            AND t2.trading_dt <= fo_ow.ds_snpst_dt
    )
