/*
*--------------------------------------------------------------------*
* Program code: atm_tthc_cl_value
* Program name: Atomic TTHC Classification Value
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT *
    FROM {{ ref('ods_tthc_classification_value') }}
)

SELECT
    CAST(src.CLASSIFICATION_CODE        AS STRING) AS cl_code
    , CAST(src.SCHEMA_CODE              AS STRING) AS schema_code
    , CAST(src.SCHEMA_NM                AS STRING) AS schema_nm
    , CAST('TTHC_CLASSIFICATION_VALUE'  AS STRING) AS src_stm_code
    , CAST(src.CLASSIFICATION_NAME      AS STRING) AS cl_nm
    , CAST(NULL                         AS STRING) AS cl_nm_english
    , CAST(src.CLASSIFICATION_DESCRIPTION AS STRING) AS cl_description
FROM src
