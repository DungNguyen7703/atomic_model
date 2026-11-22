/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value_nhnck_application_sources
* Program name: Atomic Classification Value NHNCK.APPLICATION_SOURCES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        code
        , name
        , description
    FROM {{ ref('ods_nhnck_application_sources') }}
    WHERE code IS NOT NULL
)

SELECT
    CAST(code AS string)                                     AS cl_code
    , CAST('NHNCK.APPLICATION_SOURCES' AS string)            AS schema_code
    , CAST('NHNCK - Danh mục hình thức nộp hồ sơ' AS string) AS schema_nm
    , CAST('NHNCK_APPLICATION_SOURCES' AS string)            AS src_stm_code
    , CAST(name AS string)                                   AS cl_nm
    , CAST(NULL AS string)                                   AS cl_nm_english
    , CAST(description AS string)                            AS cl_description
FROM src
