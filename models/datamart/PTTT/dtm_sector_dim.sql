/*
*--------------------------------------------------------------------*
* Program code: dtm_sector_dim
* Program name: Dtm Sector Dim
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-23		tuan.nguyenvanb		[SUA] Doi nguon atm_cl_business_line (ECAT) -> atm_cl_ids_business_line (IDS_CATEGORIES).
* 2026-10-27		tuan.nguyenvanb		[THEM NHOM 'CHUA PHAN NGANH' - BA] them 1 dong industry_code = 'UNCLASSIFIED', industry_nm = 'Chua phan nganh' (cty dai chung chua co nganh IDS) de fct_sector_risk_snpst
*									noi duoc nhom nay (xem COALESCE o pu_co cua dtm_fct_sector_risk_snpst).
*
*--------------------------------------------------------------------*
* Ghi chu:
* - Da grep toan bo models/ (khong chi PTTT) theo tu khoa "industry_dim"
*   va "sector_dim" TRUOC khi code model nay. Chi tim thay 2 model trong
*   chinh thu muc PTTT: dtm_corp_bond_industry_dim (fct_corporate_bond
*   _sector_snpst dung rieng, KHONG code lai o day) va model nay.
*   KHONG tim thay industry_dim/sector_dim nao o module khac (vi du GSDC)
*   du HLD co ghi chu "Industry Dimension da chuyen so huu sang GSDC
*   (2026-08-17)" - co the GSDC model do CHUA duoc dong bo vao repo nay
*   tai thoi diem code (can xac nhan lai voi thiet ke vien GSDC truoc
*   khi dua model nay vao production, tranh trung lap 2 dimension cung
*   muc dich).
* - dtm_sector_dim la dimension DUNG CHUNG cho fct_sector_risk_snpst,
*   KHAC voi dtm_corp_bond_industry_dim (dung rieng cho corp bond).
*   Ca 2 cung tro ve atm_cl_ids_business_line nhung tach model rieng de
*   giu dung boundary nghiep vu (Nhom 3 - Corp Bond vs Nhom 4 - Sector Risk).
* - atm_cl_ids_business_line duoc materialize theo strategy SCD2 (khong phai
*   SCD4A) nen KHONG co bang phu _hstr va KHONG co cot ds_snpst_dt.
*   Ban ghi hien hanh duoc xac dinh boi ds_rcrd_st = 'ACTIVE'
*   AND ds_rcrd_end_dt = to_date('2400-01-01') (xem mcr_scd2.sql,
*   giong cach doc cua dtm_corp_bond_industry_dim).
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
    CAST({{ generate_surrogate_key_bigint('PTTT_SECTOR', "cl_bu_li.cl_ids_business_line_code") }} AS string) AS sector_dim_id,
    CAST(cl_bu_li.cl_ids_business_line_code AS string)                                                        AS industry_code,
    CAST(cl_bu_li.cl_ids_business_line_nm AS string)                                                           AS industry_nm,
    CAST(cl_bu_li.src_stm_code AS string)                                                                  AS src_stm_code
FROM cl_bu_li

UNION ALL

SELECT
    CAST({{ generate_surrogate_key_bigint('PTTT_SECTOR', "'UNCLASSIFIED'") }} AS string) AS sector_dim_id,
    CAST('UNCLASSIFIED' AS string)                                                       AS industry_code,
    CAST('Chưa phân ngành' AS string)                                                    AS industry_nm,
    CAST('IDS_CATEGORIES' AS string)                                                     AS src_stm_code
