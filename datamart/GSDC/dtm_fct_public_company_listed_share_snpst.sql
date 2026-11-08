/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_public_company_listed_share_snpst
* Program name: Dtm Fct Public Company Listed Share Snpst
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
*									Nhom 1 - co cau co phieu (VSDC_OUTSTANDING_SHARES). Nguon VSDC
*									sparse: ods_vsdc_outstanding_shares gan ds_snpst_dt = transaction_date
*									nen chi co partition vao ngay VSDC gui.
* 2026-10-06						Doi ls_sn sang lay ban ghi VSDC moi nhat theo tung ticker
*									(transaction_date <= etl_date) - moi partition la trang thai as-of
*									etl_date day du moi ma, khong phu thuoc ngay VSDC co gui hay khong.
*									Them trans_dt_dim_id = transaction_date cua ban ghi duoc chon, de
*									dashboard hien thi "so lieu cua ngay nao" ben canh gia tri.
*									GIU snpst_dt_dim_id (= etl_date) lam partition key: neu partition
*									theo trans_dt_dim_id thi INSERT OVERWRITE dynamic se ghi de partition
*									ngay cu chi bang cac ma chua co ban ghi moi hon -> mat lich su.
* 2026-10-22						Doi tham chieu atomic theo design 2026-10-21: atm_listed_share_info
*									-> atm_listed_share_information, transaction_date -> transaction_dt.
*									Khong doi cot/kieu output.
*--------------------------------------------------------------------*
*/

WITH ls_sn AS (
    SELECT 
        ticker_symbol,
        outstanding_share_quantity,
        total_issued_share_quantity,
        treasury_share_quantity,
        free_float_share_quantity
    FROM 
        (SELECT
            ticker_symbol,
            outstanding_share_quantity,
            total_issued_share_quantity,
            treasury_share_quantity,
            free_float_share_quantity,
            row_number() over (
                partition by ticker_symbol
                order by transaction_dt desc) as rn
        FROM {{ ref('atm_listed_share_information') }}
        WHERE ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND transaction_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND src_stm_code = 'VSDC_OUTSTANDING_SHARES'
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
)

SELECT
    CAST(pc_di.public_company_dim_id AS string)                                  AS public_company_dim_id,
    Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')        AS snpst_dt_dim_id,
    CAST(ls_sn.outstanding_share_quantity AS bigint)                             AS outstanding_share_quantity,
    CAST(ls_sn.total_issued_share_quantity AS bigint)                            AS total_issued_share_quantity,
    CAST(ls_sn.treasury_share_quantity AS bigint)                                AS treasury_share_quantity,
    CAST(ls_sn.free_float_share_quantity AS bigint)                              AS free_float_share_quantity
FROM pc_di
JOIN ls_sn
    ON pc_di.equity_ticker_symbol = ls_sn.ticker_symbol
