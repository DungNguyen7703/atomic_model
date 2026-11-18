/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_company_license_condition_snpst
* Program name: Dtm Fct Securities Company License Condition Snpst
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*                   tuan.nguyenvanb     sc_al_vi_all: processing_dt-->data_dt
* 2026-10-19		claude				[SUA theo LLD] Doi ten cot join
*                                       sc_alert_ind_id -> sc_alert_
*                                       ind_id (dung ten cot that trong atomic
*                                       atm_sc_alert_violation/atm_sc_alert_
*                                       indicator). Doi indicator_code ->
*                                       sc_alert_ind_code (dung ten cot output that cua
*                                       atm_sc_alert_indicator). Bo sung cot
*                                       alert_dt tu atm_sc_alert_violation.
* 2026-11-09		tuan.nguyenvanb		[SUA theo LLD, BA 09/11, O_QLKD_73/74]
*                                       Doi grain sang 1 dong Atomic
*                                       sc_alert_violation (PK vat ly
*                                       sc_alert_violation_id), nap du lich
*                                       su - bo CTE dedupe ROW_NUMBER()/rn=1
*                                       va filter data_dt = etl_date. Bo cot
*                                       severity_level (nguon Alert Indicator,
*                                       da DEPRECATED theo K_QLKD_31). Bo sung
*                                       4 cot phan loai canh bao tu Atomic:
*                                       alert_entity_tp_code, alert_year,
*                                       rpt_period_code, alert_period_val,
*                                       severity_level_alt_code (5 cot). Doi
*                                       materialized sang incremental_rebase/
*                                       merge theo unique_key
*                                       sc_alert_violation_id (xem
*                                       schema_dtm_qlkd.yml).
* 2026-11-10		claude				[SUA theo LLD, O_QLKD_75] (1) indicator_
*                                       code lay direct tu atm_sc_alert_
*                                       violation.sc_alert_ind_code
*                                       (ALERT_INDICATOR_ID), bo CTE sc_al_in
*                                       + LEFT JOIN atm_sc_alert_indicator_
*                                       hstr. (2) Bo sung cot cuoi bang
*                                       securities_company_alert_indicator_
*                                       dim_id <- atm_sc_alert_violation.
*                                       sc_alert_ind_id (direct, khong
*                                       lookup). Phu thuoc Atomic moi (commit
*                                       b1cb5873): sc_alert_ind_id/_code cua
*                                       atm_sc_alert_violation phai tu
*                                       ALERT_INDICATOR_ID.
*--------------------------------------------------------------------*
*/

WITH sc_al_vi AS (
    SELECT
        sc_alert_violation_id,
        sc_code,
        sc_alert_ind_id,
        sc_alert_ind_code,
        alert_entity_tp_code,
        alert_year,
        rpt_period_code,
        alert_period_val,
        severity_level_alt_code,
        alert_dt
    FROM {{ ref('atm_sc_alert_violation') }}
    WHERE ds_rcrd_st = 'ACTIVE'
),

cd_dt_di AS (
    SELECT
        cdr_dt_dim_id,
        cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
),

se_co_di AS (
    SELECT
        securities_company_dim_id,
        sc_code
    FROM {{ ref('dtm_securities_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    CAST(sc_al_vi.sc_alert_violation_id AS string)      AS sc_alert_violation_id,
    CAST(cd_dt_di.cdr_dt_dim_id AS string)              AS snpst_dt_dim_id,
    CAST(se_co_di.securities_company_dim_id AS string)  AS securities_company_dim_id,
    CAST(sc_al_vi.sc_alert_ind_code AS string)          AS indicator_code,
    CAST(sc_al_vi.alert_entity_tp_code AS string)       AS alert_entity_tp_code,
    CAST(sc_al_vi.alert_year AS string)                 AS alert_year,
    CAST(sc_al_vi.rpt_period_code AS string)            AS rpt_period_code,
    CAST(sc_al_vi.alert_period_val AS int)              AS alert_period_val,
    CAST(sc_al_vi.severity_level_alt_code AS string)    AS severity_level_alt_code,
    CAST(sc_al_vi.alert_dt AS date)                     AS alert_dt,
    CAST(sc_al_vi.sc_alert_ind_id AS string)            AS securities_company_alert_indicator_dim_id
FROM sc_al_vi
LEFT JOIN cd_dt_di
    ON  cd_dt_di.cdr_dt = sc_al_vi.alert_dt
LEFT JOIN se_co_di
    ON  se_co_di.sc_code = sc_al_vi.sc_code
