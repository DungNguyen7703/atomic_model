/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value_nhnck_specializations
* Program name: Atomic Classification Value NHNCK.SPECIALIZATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        specialization_code
        , specialization_name
        , reference
    FROM {{ ref('ods_nhnck_specializations') }}
    WHERE specialization_code IS NOT NULL
)

SELECT
    CAST(specialization_code AS string)                                            AS cl_code
    , CAST('NHNCK.SPECIALIZATIONS' AS string)                                      AS schema_code
    , CAST('NHNCK - Danh mục chuyên môn/lĩnh vực hành nghề chứng khoán' AS string) AS schema_nm
    , CAST('NHNCK_SPECIALIZATIONS' AS string)                                      AS src_stm_code
    , CAST(specialization_name AS string)                                          AS cl_nm
    , CAST(NULL AS string)                                                         AS cl_nm_english
    , CAST(reference AS string)                                                    AS cl_description
FROM src
