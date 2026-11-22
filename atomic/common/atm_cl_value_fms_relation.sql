/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value_fms_relation
* Program name: Atomic Classification Value FMS.RELATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , item_name
        , description
    FROM {{ ref('ods_fms_relation') }}
    WHERE id IS NOT NULL
)

SELECT
    CAST(id AS string)                                    AS cl_code
    , CAST('FMS.RELATION' AS string)                      AS schema_code
    , CAST('FMS - Danh mục loại quan hệ' AS string)       AS schema_nm
    , CAST('FMS_RELATION' AS string)                      AS src_stm_code
    , CAST(item_name AS string)                           AS cl_nm
    , CAST(NULL AS string)                                AS cl_nm_english
    , CAST(description AS string)                         AS cl_description
FROM src
