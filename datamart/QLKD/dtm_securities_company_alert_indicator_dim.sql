/*
*--------------------------------------------------------------------*
* Program code: dtm_securities_company_alert_indicator_dim
* Program name: Dtm Securities Company Alert Indicator Dim
* Created by: claude
* Created date: 2026-11-10
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-10		claude				[MOI theo LLD, O_QLKD_75] Sinh moi -
*                                       Securities Company Alert Indicator
*                                       Dimension (Nhom 5/6/7/36), LLD
*                                       DTM_QLKD_securities_company_alert_
*                                       indicator_dim_SCMS_ALERT_INDICATOR.csv.
*                                       Nguon atm_sc_alert_indicator
*                                       (SCMS_ALERT_INDICATOR). Phu thuoc
*                                       Atomic moi (commit b1cb5873):
*                                       sc_alert_ind_code = ALERT_INDICATOR.ID,
*                                       alert_ind_code = INDICATOR_CODE,
*                                       alert_ind_nm = INDICATOR_NAME.
*                                       PK lay thang sc_alert_ind_id cua
*                                       Atomic (khong hash lai).
*--------------------------------------------------------------------*
*/

WITH sc_al_in AS (
    SELECT
        sc_alert_ind_id,
        sc_alert_ind_code,
        alert_ind_code,
        alert_ind_nm,
        alert_code,
        alert_nm,
        alert_ind_tp_code,
        severity_level,
        unit,
        legal_basis,
        src_stm_code
    FROM {{ ref('atm_sc_alert_indicator') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_ALERT_INDICATOR'
)

SELECT
    CAST(sc_alert_ind_id AS string)         AS securities_company_alert_indicator_dim_id,
    CAST(sc_alert_ind_code AS string)       AS sc_alert_ind_code,
    CAST(alert_ind_code AS string)          AS alert_ind_code,
    CAST(alert_ind_nm AS string)            AS alert_ind_nm,
    CAST(alert_code AS string)              AS alert_code,
    CAST(alert_nm AS string)                AS alert_nm,
    CAST(alert_ind_tp_code AS int)          AS alert_ind_tp_code,
    CAST(severity_level AS int)             AS severity_level,
    CAST(unit AS string)                    AS unit,
    CAST(legal_basis AS string)             AS legal_basis,
    CAST(src_stm_code AS string)            AS src_stm_code
FROM sc_al_in
