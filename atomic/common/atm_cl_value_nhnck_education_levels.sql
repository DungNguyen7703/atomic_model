/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value_nhnck_education_levels
* Program name: Atomic Classification Value NHNCK.EDUCATION_LEVELS
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
        , level_name
        , description
    FROM {{ ref('ods_nhnck_education_levels') }}
    WHERE id IS NOT NULL
)

SELECT
    CAST(id AS string)                                    AS cl_code
    , CAST('NHNCK.EDUCATION_LEVELS' AS string)            AS schema_code
    , CAST('NHNCK - Danh mục trình độ học vấn' AS string) AS schema_nm
    , CAST('NHNCK_EDUCATION_LEVELS' AS string)            AS src_stm_code
    , CAST(level_name AS string)                          AS cl_nm
    , CAST(NULL AS string)                                AS cl_nm_english
    , CAST(description AS string)                         AS cl_description
FROM src
