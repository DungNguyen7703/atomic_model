/*
*--------------------------------------------------------------------*
* Program code: atm_cl_fms_event_type
* Program name: Atomic Classification FMS Event Type
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ev_ty AS (
    SELECT
        event_code
        , item_name
        , category
        , event_category
        , obligation_type
        , deadline_calc_method
        , description
        , note
        , metadata
        , business_rule_config
        , record_status
    FROM {{ ref('ods_fms_event_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_EVENT_TYPE', "ev_ty.event_code") }} AS cl_fms_event_tp_id
    , CAST(ev_ty.event_code AS string)                                        AS cl_fms_event_tp_code
    , CAST('FMS_EVENT_TYPE' AS string)                                        AS src_stm_code
    , CAST(ev_ty.item_name AS string)                                         AS cl_fms_event_tp_nm
    , CAST(ev_ty.category AS string)                                          AS event_category_description
    , CAST(ev_ty.event_category AS string)                                    AS event_category_tp_code
    , CAST(ev_ty.obligation_type AS string)                                   AS obligation_tp_code
    , CAST(ev_ty.deadline_calc_method AS string)                              AS deadline_calc_method_code
    , CAST(ev_ty.description AS string)                                       AS description
    , CAST(ev_ty.note AS string)                                              AS note
    , CAST(ev_ty.metadata AS string)                                          AS metadata_config
    , CAST(ev_ty.business_rule_config AS string)                              AS business_rule_config
    , CAST(ev_ty.record_status AS string)                                     AS event_tp_record_status_code
FROM ev_ty