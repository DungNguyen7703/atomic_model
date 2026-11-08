/*
*--------------------------------------------------------------------*
* Program code: atm_risk_weight_config
* Program name: Atomic Risk Weight Configuration
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-24		tuan.nguyenvanb		Tao moi theo DDL design dua (atomic.uat_atm.
*									risk_weight_config, xep vao concept Business
*									Direction - KHONG con prefix cl_ o ca ten
*									model lan ten bang, sau khi design doi y tu
*									concept Classification sang Business
*									Direction), nguon la ods_uploadfile_weight
*									_config (UBCK.WEIGHT_CONFIG). Dong 1 phan gap
*									cua fct_market_risk_snpst (7 cot beta_x,
*									epsilon_error_term, weight_liquidity, weight
*									_stability, risk_index, sentiment_index) va
*									fct_cap_grp_snpst/fct_sector_risk_snpst
*									(sector_rating - gian tiep qua atm_status
*									_threshold_config).
*--------------------------------------------------------------------*
* Ghi chu:
* - Doi chieu ngu nghia voi DDL design dua: risk_weight_config chi co 4 cot
*   nghiep vu (risk_factor_code/risk_factor_nm/risk_factor_group/weight),
*   KHONG co cot "_code" rieng (khac convention <entity>_id + <entity>_code
*   thuong thay o cac atomic khac) -> hash truc tiep tren id nguon lam PK,
*   khong xuat rieng cot code.
* - Map cot: output_indicator_code (ODS) -> risk_factor_group; input_indicator
*   _code -> risk_factor_code; input_indicator_name -> risk_factor_nm; weight
*   -> weight. Suy luan tu chinh LLD DTM_PTTT_fct_market_risk_snpst.csv: moi
*   dong risk_weight_config duoc loc bang risk_factor_code (vi du
*   'VNINDEX_VOLATILITY','ILLIQ'...) VA risk_factor_type (vi du 'Chi so rui ro
*   he thong' cho nhom beta cua Risk Index, 'Chi so tam ly giao dich cua ma
*   chung khoan' cho nhom weight_liquidity/weight_stability cua Sentiment
*   Index, 'Chi so ap luc nganh' cho nhom W1/W2/W3 cua Stress Score Sector) ->
*   day chinh la 3 gia tri phan biet cua "output_indicator_code" (nhom chi so
*   tong hop dich: RISK_INDEX / SENTIMENTINDEX / STRESS_SCORE_SECTOR), dat
*   ten lai thanh risk_factor_group cho dung DDL - CAN Data Modeler/LLD xac
*   nhan lai gia tri thuc te cua output_indicator_code co khop dung 3 nhom
*   nay khong truoc production.
* - record_status/effective_date/end_date/created_at/createdby/upload_history_id
*   cua nguon UBCK.WEIGHT_CONFIG KHONG duoc map vao atomic - DDL design chi
*   co dung 4 cot nghiep vu + 4 cot ky thuat SCD2 chuan (ds_rcrd_st/ds_rcrd_eff
*   _dt/ds_rcrd_end_dt/ds_etl_pcs_tms tu macro mcr_scd2.sql, KHONG duoc SELECT
*   thu cong trong model - xem atm_fr_catalog.sql lam mau).
* - materialized: scd2 theo dung yeu cau design (khong co bang _hstr rieng,
*   luu lich su ngay trong 1 bang qua ds_rcrd_st/ds_rcrd_eff_dt/ds_rcrd_end_dt).
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
    {{ generate_surrogate_key_bigint('UBCK_WEIGHT_CONFIG', "wc.id") }}    AS risk_weight_config_id
    , CAST('UBCK_WEIGHT_CONFIG' AS string)                                AS src_stm_code
    , CAST(wc.input_indicator_code AS string)                             AS risk_factor_code
    , CAST(wc.input_indicator_name AS string)                             AS risk_factor_nm
    , CAST(wc.output_indicator_code AS string)                            AS risk_factor_group
    , CAST(wc.weight AS decimal(38,20))                                  AS weight
FROM wc
