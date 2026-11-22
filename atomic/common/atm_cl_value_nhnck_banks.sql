/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value_nhnck_banks
* Program name: Atomic Classification Value NHNCK.BANKS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        bank_code
        , bank_name
        , english_bank_name
        , short_name
    FROM {{ ref('ods_nhnck_banks') }}
    WHERE bank_code IS NOT NULL
)

SELECT
    CAST(bank_code AS string)                                             AS cl_code
    , CAST('NHNCK.BANKS' AS string)                                       AS schema_code
    , CAST('NHNCK - Danh mục ngân hàng (dùng cho nộp phí thi)' AS string) AS schema_nm
    , CAST('NHNCK_BANKS' AS string)                                       AS src_stm_code
    , CAST(bank_name AS string)                                           AS cl_nm
    , CAST(english_bank_name AS string)                                   AS cl_nm_english
    , CAST(short_name AS string)                                          AS cl_description
FROM src
