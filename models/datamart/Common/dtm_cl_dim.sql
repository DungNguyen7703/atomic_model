/*
*--------------------------------------------------------------------*
* Program code: dtm_cl_dim
* Program name: Dtm Cl Dim
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH cv AS (
    SELECT 
        schema_code, 
        schema_nm, 
        cl_code, 
        cl_nm, 
        cl_nm_english,
        cl_description,
        src_stm_code
    FROM atomic.uat_atm.cl_value
)

SELECT
    CAST({{ generate_surrogate_key_bigint('CL_VALUE', "CONCAT(schema_code, '|', cl_code)") }} AS string) AS cl_dim_id,
    CAST(schema_code AS string)                                               AS schema_code,
    CAST(schema_nm AS string)                                                 AS schema_nm,
    CAST(cl_code AS string)                                                   AS cl_code,
    CAST(cl_nm AS string)                                                     AS cl_nm,
    CAST(cl_nm_english AS string)                                             AS cl_nm_english,
    CAST(cl_description AS string)                                            AS cl_description,
    CAST(src_stm_code AS string)                                              AS src_stm_code
FROM cv
