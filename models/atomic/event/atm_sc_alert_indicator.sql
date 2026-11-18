/*
*--------------------------------------------------------------------*
* Program code: atm_sc_alert_indicator
* Program name: Atomic Securities Company Alert Indicator
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH al_in AS (
    SELECT
        id
        , indicator_code
        , indicator_name
        , alert_code
        , alert_name
        , alert_indicator_type
        , indicator_type_id
        , legal_reference
        , legal_reference_id
        , legal_basis
        , severity_level
        , severity
        , lower_threshold
        , upper_threshold
        , unit
        , default_value
        , description
        , note
        , weight
    FROM {{ ref('ods_scms_alert_indicator') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_ALERT_INDICATOR', "al_in.id") }} AS sc_alert_ind_id
    , CAST(al_in.id AS string)                                              AS sc_alert_ind_code
    , CAST(al_in.indicator_code AS string)                                  AS alert_ind_code
    , CAST('SCMS_ALERT_INDICATOR' AS string)                                AS src_stm_code
    , CAST(al_in.indicator_name AS string)                                  AS alert_ind_nm
    , CAST(al_in.alert_code AS string)                                      AS alert_code
    , CAST(al_in.alert_name AS string)                                      AS alert_nm
    , CAST(al_in.alert_indicator_type AS int)                               AS alert_ind_tp_code
    , CAST(al_in.indicator_type_id AS string)                               AS ind_tp_id
    , CAST(al_in.legal_reference AS string)                                 AS legal_reference
    , CAST(al_in.legal_reference_id AS string)                              AS legal_reference_id
    , CAST(al_in.legal_basis AS string)                                     AS legal_basis
    , CAST(al_in.severity_level AS int)                                     AS severity_level
    , CAST(al_in.severity AS int)                                           AS severity_code
    , CAST(al_in.lower_threshold AS string)                                 AS lower_threshold
    , CAST(al_in.upper_threshold AS string)                                 AS upper_threshold
    , CAST(al_in.unit AS string)                                            AS unit
    , CAST(al_in.default_value AS string)                                   AS default_val
    , CAST(al_in.description AS string)                                     AS description
    , CAST(al_in.note AS string)                                            AS note
    , CAST(al_in.weight AS decimal(5,2))                                    AS weight
FROM al_in