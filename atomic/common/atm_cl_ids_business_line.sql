/*
*--------------------------------------------------------------------*
* Program code: atm_cl_ids_business_line
* Program name: Atomic Classification IDS Business Line
* Created by: tuan.nguyenvanb
* Created date: 2026-10-23
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-23		tuan.nguyenvanb		[MOI] Theo lld_IDS_CATEGORIES (2026-10-21). Thay atm_cl_business_line
*                                       (+ 2 model ECAT level_1/level_2 da bo vi ECAT chua dung duoc).
* 2026-10-23		tuan.nguyenvanb		[SUA] Khu trung industry_cd (IDS.CATEGORIES co 2 dong / ma) - scd2 khong kiem tra dup key nen gay fan-out o mart.
*--------------------------------------------------------------------*
*/

-- Nguon IDS.CATEGORIES co moi industry_cd 2 dong (id nho 1..11 va id lon 127497..127507, cung ten) ->
-- giu 1 dong / industry_cd: uu tien active_flg = 1, roi id lon nhat (ban moi hon, vd 05000 sua loi chinh ta "dau khi").
WITH cate_all AS (
    SELECT
        id
        , industry_cd
        , industry_name
        , description
        , parent_id
        , row_number() over (partition by industry_cd order by active_flg desc nulls last, id desc) AS rn
    FROM {{ ref('ods_ids_categories') }}
    WHERE industry_cd IS NOT NULL
),

cate AS (
    SELECT
        id
        , industry_cd
        , industry_name
        , description
        , parent_id
    FROM cate_all
    WHERE rn = 1
),

cate_parent AS (
    SELECT
        id
        , industry_cd
    FROM {{ ref('ods_ids_categories') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_CATEGORIES', "cate.industry_cd") }}               AS cl_ids_business_line_id
    , CAST(cate.industry_cd AS string)                                                      AS cl_ids_business_line_code
    , CAST('IDS_CATEGORIES' AS string)                                                      AS src_stm_code
    , CAST(cate.industry_name AS string)                                                    AS cl_ids_business_line_nm
    , CAST(cate.description AS string)                                                      AS description
    , {{ generate_surrogate_key_bigint('IDS_CATEGORIES', "cate_parent.industry_cd") }}      AS parent_cl_ids_business_line_id
    , CAST(cate_parent.industry_cd AS string)                                               AS parent_cl_ids_business_line_code
FROM cate
LEFT JOIN cate_parent
    ON cate_parent.id = cate.parent_id
