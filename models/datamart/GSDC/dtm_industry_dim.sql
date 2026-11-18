/*
*--------------------------------------------------------------------*
* Program code: dtm_industry_dim
* Program name: Industry Dimension
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH business_line AS (
    SELECT
        cl_ids_business_line_code,
        cl_ids_business_line_nm,
        src_stm_code
    FROM {{ ref('atm_cl_ids_business_line') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_CATEGORIES'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('IDS_CATEGORIES', 'cl_ids_business_line_code') }} AS string) AS industry_dim_id,
    CAST(cl_ids_business_line_code AS string) AS industry_code,
    CAST(cl_ids_business_line_nm AS string)   AS industry_nm,
    CAST(src_stm_code AS string)              AS src_stm_code
FROM business_line
