/*
*--------------------------------------------------------------------*
* Program code: atm_cl_nationality
* Program name: Atomic Classification Nationality
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ca_na AS (
    SELECT
        id
        , nationality_code
        , created_at
        , nationality_name
        , record_status
        , note
    FROM {{ ref('ods_scms_cat_nationality') }}
    WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_CAT_NATIONALITY', "ca_na.nationality_code") }} AS cl_nationality_id
    , CAST(ca_na.nationality_code AS string)                                              AS cl_nationality_code
    , CAST('SCMS_CAT_NATIONALITY' AS string)                                              AS src_stm_code
    , CAST(ca_na.created_at AS date)                                                      AS data_dt
    , CAST(ca_na.nationality_name AS string)                                              AS cl_nationality_nm
    , CAST(ca_na.record_status AS string)                                                 AS record_status_code
    , CAST(ca_na.note AS string)                                                          AS note
FROM ca_na