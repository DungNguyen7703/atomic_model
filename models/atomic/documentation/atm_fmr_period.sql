/*
*--------------------------------------------------------------------*
* Program code: atm_fmr_period
* Program name: Atomic Fund Management Report Period
* Created by:
* Created date: 2026-10-17
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-17		claude				Khởi tạo theo thiết kế dm_atm_fmr_period-FMS.RPT_PERIOD.yaml
*										period_type decimal -> int -> string; send_in_day/latest_send_week/repeat_time bigint -> int
*--------------------------------------------------------------------*
*/

WITH rp_pe AS (
    SELECT
        id
        , rpt_id
        , period_type
        , send_in_day
        , latest_send_date
        , latest_send_week
        , description
        , repeat_time
    FROM {{ ref('ods_fms_rpt_period') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_RPT_PERIOD', "id") }}      AS fmr_period_id
    , CAST(id AS string)                                             AS fmr_period_code
    , CAST('FMS_RPT_PERIOD' AS string)                               AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_RPT_TEMP', "rpt_id") }}  AS fmr_id
    , CAST(rpt_id AS string)                                         AS fmr_code
    , CAST(CAST(period_type AS int) AS string)                       AS period_tp_code
    , CAST(send_in_day AS int)                                       AS send_in_day_count
    , CAST(latest_send_date AS timestamp)                            AS latest_send_tms
    , CAST(latest_send_week AS int)                                  AS latest_send_week_day_nbr
    , CAST(description AS string)                                    AS description
    , CAST(repeat_time AS int)                                       AS repeat_count
FROM rp_pe
