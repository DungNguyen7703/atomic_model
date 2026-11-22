/*
*--------------------------------------------------------------------*
* Program code: atm_cl_securities_company_event_type
* Program name: Atomic Classification Securities Company Event Type
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[MOI] Theo lld_SCMS_CAT_EVENT_TYPE.yaml (CAT_EVENT_TYPE).
* 2026-11-13		claude		[DT-Review] CAST int->bigint (nguon NUMBER(10,0)/(18,0)): cycle_code, frequency_code; cutoff_dt CAST date->string (nguon NVARCHAR2(100), user chon giu gia tri nguon; DM/LLD con date)
* 2026-11-14		claude		[Fix] cl_sc_event_tp_id = hash(SCMS_CAT_EVENT_TYPE, EVENT_TYPE_CODE) theo LLD/DM moi (BK = EVENT_TYPE_CODE), thay cho hash theo ID
*--------------------------------------------------------------------*
*/

WITH ca_ev_ty AS (
    SELECT
        id
        , event_type_code
        , event_type_name
        , requires_license
        , requires_disclosure
        , obligation_type
        , target_entity
        , event_category
        , cycle
        , frequency
        , cutoff_date
        , submission_method
        , effective_date
        , expiry_date
        , deadline_calculation_method
        , event_group_id
        , note
    FROM {{ ref('ods_scms_cat_event_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_CAT_EVENT_TYPE', "ca_ev_ty.event_type_code") }} AS cl_sc_event_tp_id
    , CAST(ca_ev_ty.event_type_code AS string)                                AS cl_sc_event_tp_code
    , CAST('SCMS_CAT_EVENT_TYPE' AS string)                                   AS src_stm_code
    , CAST(ca_ev_ty.event_type_name AS string)                                AS cl_sc_event_tp_nm
    , CAST(ca_ev_ty.requires_license AS int)                                  AS license_required_ind
    , CAST(ca_ev_ty.requires_disclosure AS int)                               AS disclosure_required_ind
    , CAST(ca_ev_ty.obligation_type AS string)                                AS obligation_tp_code
    , CAST(ca_ev_ty.target_entity AS string)                                  AS target_entity_code
    , CAST(ca_ev_ty.event_category AS string)                                 AS event_category_code
    , CAST(ca_ev_ty.cycle AS int)                                             AS cycle_code
    , CAST(ca_ev_ty.frequency AS int)                                         AS frequency_code
    , CAST(ca_ev_ty.cutoff_date AS string)                                    AS cutoff_dt
    , CAST(ca_ev_ty.submission_method AS string)                              AS submission_method
    , CAST(ca_ev_ty.effective_date AS date)                                   AS effective_dt
    , CAST(ca_ev_ty.expiry_date AS date)                                      AS expiry_dt
    , CAST(ca_ev_ty.deadline_calculation_method AS string)                    AS deadline_calculation_method_code
    , CAST(ca_ev_ty.event_group_id AS string)                                 AS event_group_id
    , CAST(ca_ev_ty.note AS string)                                           AS note
FROM ca_ev_ty
