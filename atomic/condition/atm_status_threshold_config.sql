/*
*--------------------------------------------------------------------*
* Program code: atm_status_threshold_config
* Program name: Atomic Status Threshold Configuration
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH tc AS (
    SELECT
        id
        , indicator_code
        , indicator_name
        , value_from
        , value_to
        , status
    FROM {{ ref('ods_uploadfile_threshold_config') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_THRESHOLD_CONFIG', "concat_ws('-', indicator_code, status)") }}    AS status_threshold_config_id
    , CAST(concat_ws('-', indicator_code, status) AS string)                                                 AS status_threshold_config_code
    , CAST('FMS_THRESHOLD_CONFIG' AS string)                                                                 AS src_stm_code
    , CAST(indicator_code AS string)                                                                         AS index_code
    , CAST(indicator_name AS string)                                                                         AS index_nm
    , CAST(value_from AS decimal(5,2))                                                                       AS from_val
    , CAST(value_to AS decimal(5,2))                                                                         AS to_val
    , CAST(status AS string)                                                                                 AS status
FROM tc
