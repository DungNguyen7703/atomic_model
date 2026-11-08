/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_public_company_state_capital_snpst
* Program name: Dtm Fct Public Company State Capital Snpst
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
*									Nhom 3 - von Nha nuoc (IDS_STATE_CAPITAL). stg_ids_state_capital
*									full-mirror nen atm_pc_state_capital_hstr co partition moi etl_date.
*									Truoc day group theo ticker roi join lai ls_sn (cong ty khong co
*									ban ghi VSDC thi mat von NN) - nay drive tu chinh sc, group theo
*									public_company_dim_id.
*--------------------------------------------------------------------*
*/

WITH sc_filtered AS (
    SELECT
        pc_code,
        owned_share_quantity,
        ownership_ratio_percentage
    FROM {{ ref('atm_pc_state_capital') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_STATE_CAPITAL'
),

pc_di AS (
    SELECT
        public_company_dim_id,
        public_company_code
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
)

SELECT
    CAST(pc_di.public_company_dim_id AS string)                               AS public_company_dim_id,
    Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')     AS snpst_dt_dim_id,
    CAST(SUM(sc.owned_share_quantity) AS bigint)                              AS state_owned_share_quantity,
    CAST(SUM(sc.ownership_ratio_percentage) AS decimal(5,2))                  AS state_ownership_ratio_percentage
FROM pc_di
JOIN sc_filtered sc
    ON pc_di.public_company_code = sc.pc_code
GROUP BY pc_di.public_company_dim_id
