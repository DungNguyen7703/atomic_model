/*
*--------------------------------------------------------------------*
* Program code: atm_sc_report_x_cl_sc_event_type_relationship
* Program name: Atomic Securities Company Report X Classification Securities Company Event Type Relationship
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_LNK_EVENT_TYPE_FORM.yaml (8 cot, Relative/scd2, PK (sc_rpt_id, cl_sc_event_tp_id)); khoi phuc tu git 77a9749^
* 2026-11-13		claude		[MOI] cl_sc_event_tp_id hash SCMS_CAT_EVENT_TYPE theo ID (khop PK atm_cl_securities_company_event_type = hash(.., ID) va source_columns LLD); comment LLD ghi 'EVENT_TYPE_CODE' -> mau thuan, can Data Modeler xac nhan. cl_sc_event_tp_code = CAT_EVENT_TYPE.EVENT_TYPE_CODE (crosswalk)
* 2026-11-14		claude		[Fix] LLD/DM da chot BK = EVENT_TYPE_CODE: cl_sc_event_tp_id = hash(SCMS_CAT_EVENT_TYPE, ca_ev_ty.event_type_code) (crosswalk LNK.event_type_id = CAT_EVENT_TYPE.id), khop PK atm_cl_securities_company_event_type
* 2026-11-13		claude		[MOI] Khu trung theo cap (form_report_id, event_type_id) bang ROW_NUMBER (id lon nhat) vi khoa composite khong phai PK nguon
*--------------------------------------------------------------------*
*/

WITH ln_ev_ty_fo AS (
    SELECT
        form_report_id
        , event_type_id
        , applicable_from
        , applicable_to
        , required
    FROM {{ ref('ods_scms_lnk_event_type_form') }}
),

ca_ev_ty AS (
    SELECT
        id
        , event_type_code
    FROM {{ ref('ods_scms_cat_event_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_LNK_EVENT_TYPE_FORM', "ln_ev_ty_fo.form_report_id") }}    AS sc_rpt_id
    , CAST(ln_ev_ty_fo.form_report_id AS string)                                                     AS sc_rpt_code
    , {{ generate_surrogate_key_bigint('SCMS_CAT_EVENT_TYPE', "ca_ev_ty.event_type_code") }}         AS cl_sc_event_tp_id
    , CAST(ca_ev_ty.event_type_code AS string)                                                       AS cl_sc_event_tp_code
    , CAST('SCMS_LNK_EVENT_TYPE_FORM' AS string)                                                     AS src_stm_code
    , CAST(ln_ev_ty_fo.applicable_from AS date)                                                      AS applicable_from_dt
    , CAST(ln_ev_ty_fo.applicable_to AS date)                                                        AS applicable_to_dt
    , CAST(ln_ev_ty_fo.required AS int)                                                              AS required_ind
FROM ln_ev_ty_fo
    LEFT JOIN ca_ev_ty ON ln_ev_ty_fo.event_type_id = ca_ev_ty.id