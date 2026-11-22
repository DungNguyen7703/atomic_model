/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value_nhnck_departments
* Program name: Atomic Classification Value NHNCK.DEPARTMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        department_code
        , department_name
        , description
    FROM {{ ref('ods_nhnck_departments') }}
    WHERE department_code IS NOT NULL
)

SELECT
    CAST(department_code AS string)                                    AS cl_code
    , CAST('NHNCK.DEPARTMENTS' AS string)                              AS schema_code
    , CAST('NHNCK - Danh mục phòng ban thuộc đơn vị UBCKNN' AS string) AS schema_nm
    , CAST('NHNCK_DEPARTMENTS' AS string)                              AS src_stm_code
    , CAST(department_name AS string)                                  AS cl_nm
    , CAST(NULL AS string)                                             AS cl_nm_english
    , CAST(description AS string)                                      AS cl_description
FROM src
