/*
*--------------------------------------------------------------------*
* Program code: atm_cl_ecat_department
* Program name: Atomic Classification ECAT Department
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[MOI] Theo lld_ECAT_DEPARTMENT.yaml (2026-10-22), cung pattern atm_cl_ids_business_line (Relative -> scd2). Khu trung theo code (scd2 khong kiem tra dup key).
*--------------------------------------------------------------------*
*/

WITH de_all AS (
    SELECT
        code
        , name
        , description
        , phone
        , email
        , row_number() over (partition by code order by version desc nulls last, updated_at desc nulls last, id desc) AS rn
    FROM {{ ref('ods_ecat_department') }}
    WHERE code IS NOT NULL
)

SELECT
    {{ generate_surrogate_key_bigint('ECAT_DEPARTMENT', "de_all.code") }} AS cl_ecat_department_id
    , CAST(de_all.code AS string)                                         AS cl_ecat_department_code
    , CAST('ECAT_DEPARTMENT' AS string)                                   AS src_stm_code
    , CAST(de_all.name AS string)                                         AS cl_ecat_department_nm
    , CAST(de_all.description AS string)                                  AS description
    , CAST(de_all.phone AS string)                                        AS phone_nbr
    , CAST(de_all.email AS string)                                        AS email_adr
FROM de_all
WHERE de_all.rn = 1
