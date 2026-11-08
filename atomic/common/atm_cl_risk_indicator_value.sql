/*
*--------------------------------------------------------------------*
* Program code: atm_cl_risk_indicator_value
* Program name: Atomic Classification Risk Indicator Value
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ri_in_va AS (
    SELECT
        id
        , indicator_id
        , period_type
        , period_value
        , period_year
        , period_date
        , period_label
        , value
        , cumulative_value
        , unit_code
        , source_code
        , data_origin
    FROM {{ ref('ods_mrms_risk_indicator_value') }}
--WHERE period_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

ri_in AS (
    SELECT
        id
        , indicator_code
    FROM {{ ref('ods_mrms_risk_indicator') }}
)

SELECT
    {{ generate_surrogate_key_bigint('MRMS_RISK_INDICATOR_VALUE', "ri_in_va.id") }}      AS cl_risk_ind_val_id
    , CAST(ri_in_va.id AS string)                                                        AS cl_risk_ind_val_code
    , CAST('MRMS_RISK_INDICATOR_VALUE' AS string)                                        AS src_stm_code
    , {{ generate_surrogate_key_bigint('MRMS_RISK_INDICATOR', "ri_in.indicator_code") }} AS cl_risk_ind_id
    , CAST(ri_in.indicator_code AS string)                                               AS cl_risk_ind_code
    , CAST(ri_in_va.period_type AS string)                                               AS period_tp_code
    , CAST(ri_in_va.period_value AS int)                                                 AS period_val
    , CAST(ri_in_va.period_year AS int)                                                  AS period_year
    , CAST(ri_in_va.period_date AS date)                                                 AS period_dt
    , CAST(ri_in_va.period_label AS string)                                              AS period_label
    , CAST(ri_in_va.value AS decimal(23,2))                                              AS val
    , CAST(ri_in_va.cumulative_value AS decimal(23,2))                                   AS cumulative_val
    , CAST(ri_in_va.unit_code AS string)                                                 AS unit_tp_code
    , CAST(ri_in_va.source_code AS string)                                               AS data_src_tp_code
    , CAST(ri_in_va.data_origin AS string)                                               AS data_origin_tp_code
FROM ri_in_va
    LEFT JOIN ri_in ON ri_in_va.INDICATOR_ID = ri_in.ID