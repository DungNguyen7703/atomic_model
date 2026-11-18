/*
*--------------------------------------------------------------------*
* Program code: stg_iam_user_ext_individual_categories
* Program name: Staging IAM.USER_EXT_INDIVIDUAL_CATEGORIES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo UAT_IAM_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(user_id AS string)       AS user_id
    , CAST(category_code AS string) AS category_code
    , CAST(is_required AS int)      AS is_required
FROM {{ source('source_iam', 'raw_user_ext_individual_categories') }}