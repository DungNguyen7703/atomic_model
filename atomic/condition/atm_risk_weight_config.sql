/*
*--------------------------------------------------------------------*
* Program code: atm_risk_weight_config
* Program name: Atomic Risk Weight Configuration
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH wc AS (
    SELECT
        id
        , output_indicator_code
        , input_indicator_code
        , input_indicator_name
        , weight
    FROM {{ ref('ods_uploadfile_weight_config') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_WEIGHT_CONFIG', "concat_ws('-', input_indicator_code, output_indicator_code)") }}    AS risk_weight_config_id
    , CAST(concat_ws('-', input_indicator_code, output_indicator_code) AS string)                                              AS risk_weight_config_code
    , CAST('FMS_WEIGHT_CONFIG' AS string)                                                                                      AS src_stm_code
    , CAST(input_indicator_code AS string)                                                                                     AS risk_factor_code
    , CAST(input_indicator_name AS string)                                                                                     AS risk_factor_nm
    , CAST(output_indicator_code AS string)                                                                                    AS risk_factor_group
    , CAST(weight AS decimal(5,2))                                                                                             AS weight
FROM wc
