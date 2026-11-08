/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_company_capital_raising_event
* Program name: Dtm Fct Securities Company Capital Raising Event
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		claude			[SUA theo LLD 2026-10-12/2026-10-15] Truc
*                                       ngay doi tu result_rpt_dt (NULL 84/84
*                                       dong CP/TP) sang document_dt. LLD yeu
*                                       cau COALESCE(document_dt, CAST(
*                                       src_rcrd_isrt_tms AS DATE)) nhung
*                                       atm_sc_disclosure_securities_offering
*                                       KHONG co cot audit insert-timestamp
*                                       nao (da kiem tra toan bo output cot) -
*                                       GAP ATOMIC, xem O_QLKD_39. Tam dung
*                                       document_dt don (khong COALESCE duoc)
*                                       cho toi khi Atomic bo sung cot nay.
*                                       Doi cong thuc classify offering_form
*                                       sang dung chung voi dtm_offering_form_
*                                       dim (offering_tp_code/offering_method
*                                       CASE 1/7/3/8), bo sung filter
*                                       item_category_code IN ('CP','TP').
* 2026-10-24		claude			[SUA theo LLD, O_QLKD_39 da duoc atomic bu
*                                       dap] atm_sc_disclosure_securities_
*                                       offering nay da co cot
*                                       src_record_insert_tms. Doi event_mth
*                                       sang COALESCE(document_dt, CAST(
*                                       src_record_insert_tms AS DATE)) dung
*                                       cong thuc LLD cho event_dt_dim_id, bo
*                                       ghi chu GAP ATOMIC da loi thoi.
* 2026-10-24		claude			[SUA theo LLD, O_QLKD_54] Bo dieu kien
*                                       TRUNC(ngay,'MM') = TRUNC(:etl_date,'MM')
*                                       - nguon nho (vai tram dong), ETL nap
*                                       lai TOAN BO moi thang co du lieu moi
*                                       lan chay (TRUNCATE + INSERT, dong bo
*                                       voi flat qlkd_fct_securities_company_
*                                       capital_raising_event_flat), tranh bo
*                                       lot dot chao ban cong bo/bo sung lui
*                                       ngay (vd document_dt NULL tao thang
*                                       11/2025).
*--------------------------------------------------------------------*
*/

WITH sc_di_se_of AS (
    SELECT
        proceeds_collected_amt,
        document_dt,
        src_record_insert_tms,
        item_category_code,
        offering_tp_code,
        offering_method
    FROM {{ ref('atm_sc_disclosure_securities_offering') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_DISCLOSURE_SECURITIES_OFFERING'
        AND item_category_code IN ('CP','TP')
),

classified AS (
    SELECT
        proceeds_collected_amt,
        trunc(COALESCE(document_dt, CAST(src_record_insert_tms AS DATE)),'MM') AS event_mth,
        item_category_code,
        COALESCE(
            offering_tp_code,
            CASE offering_method
                WHEN 'CHAO_BAN_RA_CONG_CHUNG' THEN 1
                WHEN 'CHAO_BAN_RIENG_LE'      THEN 7
                WHEN 'TRA_CO_TUC_BANG_CP'     THEN 3
                ELSE CASE WHEN NULLIF(TRIM(offering_method),'') IS NOT NULL THEN 8 END
            END
        ) AS offering_tp_resolved
    FROM sc_di_se_of
),

derived AS (
    SELECT
        proceeds_collected_amt,
        event_mth,
        CASE
            WHEN item_category_code = 'CP' AND offering_tp_resolved = 1 THEN 'PUBLIC_STOCK_OFFERING'
            WHEN item_category_code = 'CP' AND offering_tp_resolved = 7 THEN 'PRIVATE_STOCK_OFFERING'
            WHEN item_category_code = 'CP' AND offering_tp_resolved IS NOT NULL THEN 'OTHER_STOCK_OFFERING'
            WHEN item_category_code = 'TP' AND offering_tp_resolved = 7 THEN 'PRIVATE_BOND_ISSUANCE'
            WHEN item_category_code = 'TP' AND offering_tp_resolved = 1 THEN 'PUBLIC_BOND_ISSUANCE'
        END AS capital_raising_form_code
    FROM classified
),

cd_dt_di AS (
    SELECT
        cdr_dt_dim_id,
        cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
),

of_fo_di AS (
    SELECT
        offering_form_dim_id,
        capital_raising_form_code
    FROM {{ ref('dtm_offering_form_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    CAST(cd_dt_di.cdr_dt_dim_id AS string)                       AS event_dt_dim_id,
    CAST(of_fo_di.offering_form_dim_id AS string)                AS offering_form_dim_id,
    CAST(SUM(derived.proceeds_collected_amt) AS decimal(23,2))  AS proceeds_collected_amt
FROM derived
LEFT JOIN cd_dt_di
    ON  cd_dt_di.cdr_dt = derived.event_mth
LEFT JOIN of_fo_di
    ON  of_fo_di.capital_raising_form_code = derived.capital_raising_form_code
GROUP BY cd_dt_di.cdr_dt_dim_id, of_fo_di.offering_form_dim_id
