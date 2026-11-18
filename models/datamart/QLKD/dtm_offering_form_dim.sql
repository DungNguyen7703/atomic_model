/*
*--------------------------------------------------------------------*
* Program code: dtm_offering_form_dim
* Program name: Dtm Offering Form Dim
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		claude			[SUA theo LLD 2026-10-15, Data Modeler]
*                                       Doi tu LIKE text-matching sang dung
*                                       cong thuc LLD: COALESCE(offering_tp_
*                                       code, CASE offering_method
*                                       WHEN 'CHAO_BAN_RA_CONG_CHUNG' THEN 1
*                                       WHEN 'CHAO_BAN_RIENG_LE' THEN 7
*                                       WHEN 'TRA_CO_TUC_BANG_CP' THEN 3
*                                       ELSE 8 END), roi map 1/7/8(CP)/
*                                       7/1(TP) sang 5 ma hinh thuc tang von.
*                                       Tu dong dung offering_tp_code khi
*                                       Atomic nap gia tri (hien NULL 100%).
*--------------------------------------------------------------------*
*/

WITH sc_di_se_of AS (
    SELECT
        item_category_code,
        offering_tp_code,
        offering_method,
        src_stm_code
    FROM {{ ref('atm_sc_disclosure_securities_offering') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_DISCLOSURE_SECURITIES_OFFERING'
),

classified AS (
    SELECT
        src_stm_code,
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
        src_stm_code,
        CASE
            WHEN item_category_code = 'CP' AND offering_tp_resolved = 1 THEN 'PUBLIC_STOCK_OFFERING'
            WHEN item_category_code = 'CP' AND offering_tp_resolved = 7 THEN 'PRIVATE_STOCK_OFFERING'
            WHEN item_category_code = 'CP' AND offering_tp_resolved IS NOT NULL THEN 'OTHER_STOCK_OFFERING'
            WHEN item_category_code = 'TP' AND offering_tp_resolved = 7 THEN 'PRIVATE_BOND_ISSUANCE'
            WHEN item_category_code = 'TP' AND offering_tp_resolved = 1 THEN 'PUBLIC_BOND_ISSUANCE'
        END AS capital_raising_form_code,
        CASE
            WHEN item_category_code = 'CP' AND offering_tp_resolved = 1 THEN 'Chào bán ra công chúng'
            WHEN item_category_code = 'CP' AND offering_tp_resolved = 7 THEN 'Chào bán riêng lẻ'
            WHEN item_category_code = 'CP' AND offering_tp_resolved IS NOT NULL THEN 'Chào bán khác'
            WHEN item_category_code = 'TP' AND offering_tp_resolved = 7 THEN 'Phát hành TP riêng lẻ'
            WHEN item_category_code = 'TP' AND offering_tp_resolved = 1 THEN 'Phát hành TP ra công chúng'
        END AS capital_raising_form_nm
    FROM classified
)

SELECT DISTINCT
    CAST({{ generate_surrogate_key_bigint('SCMS_DISCLOSURE_SECURITIES_OFFERING', 'capital_raising_form_code') }} AS string) AS offering_form_dim_id,
    CAST(capital_raising_form_code AS string) AS capital_raising_form_code,
    CAST(capital_raising_form_nm AS string)   AS capital_raising_form_nm,
    CAST(src_stm_code AS string)              AS src_stm_code
FROM derived
