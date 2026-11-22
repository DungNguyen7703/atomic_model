/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value_nhnck_documents
* Program name: Atomic Classification Value NHNCK.DOCUMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        document_code
        , document_name
        , reference
    FROM {{ ref('ods_nhnck_documents') }}
    WHERE document_code IS NOT NULL
)

SELECT
    CAST(document_code AS string)                                                     AS cl_code
    , CAST('NHNCK.DOCUMENTS' AS string)                                               AS schema_code
    , CAST('NHNCK - Danh mục các tài liệu/hồ sơ cần nộp theo thủ tục CCHN' AS string) AS schema_nm
    , CAST('NHNCK_DOCUMENTS' AS string)                                               AS src_stm_code
    , CAST(document_name AS string)                                                   AS cl_nm
    , CAST(NULL AS string)                                                            AS cl_nm_english
    , CAST(reference AS string)                                                       AS cl_description
FROM src
