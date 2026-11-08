/*
*--------------------------------------------------------------------*
* Program code: stg_knt_cat_violation_act
* Program name: Staging KNT.CAT_VIOLATION_ACT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                     AS id
    , CAST(violation_act_code AS string)     AS violation_act_code
    , CAST(violation_act_name AS string)     AS violation_act_name
    , CAST(last_modified_at AS date)         AS last_modified_at
    , CAST(created_by_id AS string)          AS created_by_id
    , CAST(description AS string)            AS description
    , CAST(legal_basis_doc AS string)        AS legal_basis_doc
    , CAST(violation_handling_doc AS string) AS violation_handling_doc
    , CAST(status AS int)                    AS status
FROM {{ source('source_knt', 'raw_cat_violation_act') }}