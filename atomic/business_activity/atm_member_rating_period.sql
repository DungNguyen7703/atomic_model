/*
*--------------------------------------------------------------------*
* Program code: atm_member_rating_period
* Program name: Atomic Member Rating Period
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Sync LLD Atomic FMS UAT 20261006 (lld_FMS_RATING_PD.yaml): bo active_status_flag. Giu ten member_rating_period_*
*										(LLD ghi m_ember_* — loi chinh ta, da bao Data Modeler). GIU rating_data_update_dt (UPDATE_DATA_RATING)
*										du LLD Atomic chua khai bao — Mart QLQ dtm_opr_fund_management_company_profile can cot nay de chon ky moi nhat
*--------------------------------------------------------------------*
*/

WITH ra_pd AS (
    SELECT
        id
        , report_year
        , period
        , update_data_rating
        , rating_finalized
    FROM {{ ref('ods_fms_rating_pd') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_RATING_PD', "ra_pd.id") }} AS member_rating_period_id
    , CAST(ra_pd.id AS string)                                       AS member_rating_period_code
    , CAST('FMS_RATING_PD' AS string)                                AS src_stm_code
    , CAST(ra_pd.report_year AS int)                                 AS rpt_year
    , CAST(ra_pd.period AS string)                                   AS rating_period_tp_code
    , CAST(ra_pd.update_data_rating AS date)                         AS rating_data_update_dt
    , CAST(ra_pd.rating_finalized AS int)                            AS rating_finalized_flag
FROM ra_pd