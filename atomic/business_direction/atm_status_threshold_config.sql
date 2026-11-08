/*
*--------------------------------------------------------------------*
* Program code: atm_status_threshold_config
* Program name: Atomic Status Threshold Configuration
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-24		tuan.nguyenvanb		Tao moi theo DDL design dua (atomic.uat_atm.
*									status_threshold_config, xep vao concept
*									Business Direction - KHONG con prefix cl_ o
*									ca ten model lan ten bang, sau khi design doi
*									y tu concept Classification sang Business
*									Direction), nguon la ods_uploadfile_threshold
*									_config (UBCK.THRESHOLD_CONFIG). Dong gap cho
*									cac cot LOOKUP status o fct_market_risk_snpst
*									(sentiment_index_status/margin_tension_status/
*									margin_stress_status/systemic_vol_status/
*									turnover_velocity_status), fct_cap_grp_snpst
*									(cap_group_code) va fct_sector_risk_snpst
*									(sector_rating).
*--------------------------------------------------------------------*
* Ghi chu:
* - Doi chieu ngu nghia voi DDL design dua: 1-1 khop hoan toan voi cot cua
*   ods_uploadfile_threshold_config (indicator_code -> index_code,
*   indicator_name -> index_name, value_from -> from_value, value_to ->
*   to_value, status -> status).
* - Giong atm_risk_weight_config: KHONG co cot "_code" rieng, hash truc tiep
*   tren id nguon lam PK; record_status/effective_date/end_date/created_at/
*   createdby/upload_history_id KHONG duoc map (DDL design chi co 5 cot
*   nghiep vu + 4 cot ky thuat SCD2 chuan tu macro mcr_scd2.sql).
* - materialized: scd2 theo dung yeu cau design (khong co bang _hstr rieng).
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
    {{ generate_surrogate_key_bigint('UBCK_THRESHOLD_CONFIG', "tc.id") }}    AS status_threshold_config_id
    , CAST('UBCK_THRESHOLD_CONFIG' AS string)                               AS src_stm_code
    , CAST(tc.indicator_code AS string)                                     AS index_code
    , CAST(tc.indicator_name AS string)                                     AS index_name
    , CAST(tc.value_from AS decimal(18,2))                                          AS from_value
    , CAST(tc.value_to AS decimal(18,2))                                            AS to_value
    , CAST(tc.status AS string)                                             AS status
FROM tc
