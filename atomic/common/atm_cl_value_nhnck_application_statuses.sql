/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value_nhnck_application_statuses
* Program name: Atomic Classification Value NHNCK.APPLICATION_STATUSES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        status_code
        , status_name
        , description
    FROM {{ ref('ods_nhnck_application_statuses') }}
    WHERE status_code IS NOT NULL
)

SELECT
    CAST(status_code AS string)                                                   AS cl_code
    , CAST('NHNCK.APPLICATION_STATUSES' AS string)                                AS schema_code
    , CAST('NHNCK - Danh mục trạng thái hồ sơ của Chứng chỉ hành nghề' AS string) AS schema_nm
    , CAST('NHNCK_APPLICATION_STATUSES' AS string)                                AS src_stm_code
    , CAST(status_name AS string)                                                 AS cl_nm
    , CAST(NULL AS string)                                                        AS cl_nm_english
    , CAST(description AS string)                                                 AS cl_description
FROM src
