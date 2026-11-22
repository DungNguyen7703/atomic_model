/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value_nhnck_positions
* Program name: Atomic Classification Value NHNCK.POSITIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        position_code
        , position_name
        , description
    FROM {{ ref('ods_nhnck_positions') }}
    WHERE position_code IS NOT NULL
)

SELECT
    CAST(position_code AS string)                AS cl_code
    , CAST('NHNCK.POSITIONS' AS string)          AS schema_code
    , CAST('NHNCK - Danh mục chức vụ' AS string) AS schema_nm
    , CAST('NHNCK_POSITIONS' AS string)          AS src_stm_code
    , CAST(position_name AS string)              AS cl_nm
    , CAST(NULL AS string)                       AS cl_nm_english
    , CAST(description AS string)                AS cl_description
FROM src
