/*
*--------------------------------------------------------------------*
* Program code: dtm_corp_bond_industry_dim
* Program name: Dtm Corp Bond Industry Dim
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-23		tuan.nguyenvanb		[SUA] Doi nguon atm_cl_business_line (ECAT) -> atm_cl_ids_business_line (IDS_CATEGORIES).
*
*--------------------------------------------------------------------*
* Ghi chu:
* - atm_cl_ids_business_line duoc materialize theo strategy SCD2 (khong phai
*   SCD4A) nen KHONG co bang phu _hstr va KHONG co cot ds_snpst_dt.
*   Ban ghi hien hanh duoc xac dinh boi ds_rcrd_st = 'ACTIVE'
*   AND ds_rcrd_end_dt = to_date('2400-01-01') (xem mcr_scd2.sql).
* - Lay toan bo nganh IDS_CATEGORIES (ECAT chua dung duoc nen bo ECAT_BUSINESS_LINE_LEVEL_1).
*--------------------------------------------------------------------*
*/

WITH cl_bu_li AS (
    SELECT
        cl_ids_business_line_code
        , cl_ids_business_line_nm
        , src_stm_code
    FROM {{ ref('atm_cl_ids_business_line') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND ds_rcrd_end_dt = to_date('2400-01-01')
        AND src_stm_code = 'IDS_CATEGORIES'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('PTTT_CORP_BOND_INDUSTRY', "cl_bu_li.cl_ids_business_line_code") }} AS string) AS corp_bond_industry_dim_id,
    CAST(cl_bu_li.cl_ids_business_line_code AS string)                                                                   AS industry_code,
    CAST(cl_bu_li.cl_ids_business_line_nm AS string)                                                                     AS industry_nm,
    CAST(cl_bu_li.src_stm_code AS string)                                                                            AS src_stm_code
FROM cl_bu_li
