

WITH src AS (
    SELECT
        classification_code
        , schema_code
        , schema_nm
        , classification_name
        , data_dt
    FROM {{ ref('ods_tthc_classification_value') }}
),

deduped AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY classification_code, schema_code ORDER BY data_dt DESC) AS rn
        FROM src
    ) t
    WHERE rn = 1
)

SELECT
    CAST(deduped.classification_code    AS string) AS cl_code
    , CAST(deduped.schema_code          AS string) AS schema_code
    , CAST(deduped.schema_nm            AS string) AS schema_nm
    , CAST('TTHC_CLASSIFICATION_VALUE'  AS string) AS src_stm_code
    , CAST(deduped.classification_name  AS string) AS cl_nm
    , CAST(NULL                         AS string) AS cl_nm_english
    , CAST(NULL                         AS string) AS cl_description
FROM deduped
