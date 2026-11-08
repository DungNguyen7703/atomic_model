/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_public_company_foreign_holding_snpst
* Program name: Dtm Fct Public Company Foreign Holding Snpst
* Created by:
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05						Tach tu dtm_fct_public_company_listing_info_snpst (BA chot): moi
*									nhom chi so 1 bang/1 job rieng vi tang khai thac loc theo ngay chan
*									can lay MAX(snpst_dt) <= ngay chan DOC LAP cho tung nhom - gop chung
*									1 bang thi cac nhom dung chung 1 ngay snapshot, nhom nao nguon khong
*									publish dung ngay do se ra NULL du da co du lieu ngay truoc.
*									Mart chi ghi partition snpst_dt_dim_id = etl_date khi nguon co du
*									lieu dung ngay do (ds_snpst_dt = etl_date), KHONG carry-forward -
*									carry-forward do ClickHouse resolve (xem note 2026-09-11 trong git log
*									listing_info cu).
*									Nhom 2 - so huu NDTNN (VSDC_FOREIGN_INVESTOR_INFO) + foreign_holding_value
*									(K_NDTNN_51) = current_foreign_holding_quantity x close_price gan
*									nhat <= etl_date. Ten bang dung 'foreign_holding' tranh trung
*									ten ..._foreign_ownership_snpst cua domain NDTNN.
*--------------------------------------------------------------------*
*/

WITH fo_sn AS (
    SELECT 
        ticker_symbol,
        current_foreign_holding_quantity,
        total_issued_share_quantity,
        max_foreign_ownership_ratio,
        remaining_foreign_holding_quantity
    FROM 
        (SELECT
            ticker_symbol,
            current_foreign_holding_quantity,
            total_issued_share_quantity,
            max_foreign_ownership_ratio,
            remaining_foreign_holding_quantity,
            row_number () over (
                partition by ticker_symbol 
                order by ds_snpst_dt desc
            ) as rn
        FROM {{ ref('atm_foreign_ownership_information') }}
        WHERE ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND src_stm_code = 'VSDC_FOREIGN_INVESTOR_INFO'
        )
    WHERE rn = 1
),

pc_di AS (
    SELECT
        public_company_dim_id,
        equity_ticker_symbol
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
),

se_tr_sn AS (
    SELECT
        ticker_symbol,
        close_price
    FROM
        (SELECT
            ticker_symbol,
            close_price,
            row_number() over (
                partition by ticker_symbol
                order by trading_dt desc, trading_time desc) as rn
        FROM {{ ref('atm_security_trading_snapshot') }}
        WHERE ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND trading_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        )
    WHERE rn = 1
)

SELECT
    CAST(pc_di.public_company_dim_id AS string)                               AS public_company_dim_id,
    Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')     AS snpst_dt_dim_id,
    CAST(fo_sn.current_foreign_holding_quantity AS bigint)                    AS current_foreign_holding_quantity,
    CAST(100 * fo_sn.current_foreign_holding_quantity / NULLIF(fo_sn.total_issued_share_quantity, 0) AS decimal(5,2))
                                                                              AS foreign_ownership_ratio,
    CAST(fo_sn.max_foreign_ownership_ratio AS decimal(5,2))                   AS max_foreign_ownership_ratio,
    CAST(fo_sn.remaining_foreign_holding_quantity AS bigint)                  AS remaining_foreign_holding_quantity,
    CAST(fo_sn.current_foreign_holding_quantity * se_tr_sn.close_price AS decimal(23,2))
                                                                              AS foreign_holding_value
FROM pc_di
JOIN fo_sn
    ON pc_di.equity_ticker_symbol = fo_sn.ticker_symbol
LEFT JOIN se_tr_sn
    ON se_tr_sn.ticker_symbol = fo_sn.ticker_symbol
