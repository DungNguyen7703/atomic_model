/*
*--------------------------------------------------------------------*
* Program code: atm_cl_risk_indicator
* Program name: Atomic Classification Risk Indicator
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ri_in AS (
    SELECT
        id
        , indicator_code
        , indicator_name
        , set_code
        , period_type
        , unit_code
        , source_code
        , last_sync_time
    FROM {{ ref('ods_mrms_risk_indicator') }}
),

ri_in_ca AS (
    SELECT
        id
        , category_code
    FROM {{ ref('ods_mrms_risk_indicator_category') }}
)

SELECT
    {{ generate_surrogate_key_bigint('MRMS_RISK_INDICATOR', "ri_in.indicator_code") }} AS cl_risk_ind_id
    , CAST(ri_in.indicator_code AS string)                                             AS cl_risk_ind_code
    , CAST('MRMS_RISK_INDICATOR' AS string)                                            AS src_stm_code
    , CAST(ri_in.indicator_name AS string)                                             AS ind_nm
    , CAST(ri_in_ca.category_code AS string)                                           AS risk_ind_category_code
    , CAST(ri_in.set_code AS string)                                                   AS set_tp_code
    , CAST(ri_in.period_type AS string)                                                AS period_tp_code
    , CAST(ri_in.unit_code AS string)                                                  AS unit_tp_code
    , CAST(ri_in.source_code AS string)                                                AS data_src_tp_code
    , CAST(ri_in.last_sync_time AS timestamp)                                          AS last_sync_tms
FROM ri_in
    LEFT JOIN ri_in_ca ON ri_in.id = ri_in_ca.id