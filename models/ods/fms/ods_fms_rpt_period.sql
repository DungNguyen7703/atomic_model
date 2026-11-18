/*
*--------------------------------------------------------------------*
* Program code: ods_fms_rpt_period
* Program name: ODS FMS.RPT_PERIOD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-17		tuan.nguyenvanb		[MOI] ODS FMS.RPT_PERIOD - nguon cua atm_fmr_period (thiet ke moi). Cung pattern ods_fms_rpt_temp.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , rpt_id
    , period_type
    , record_status
    , working_day
    , send_in_day
    , latest_send_date
    , latest_send_week
    , description
    , sf_pd_id
    , repeat_time
    , announce_is_working_day
    , announce_latest_send_date
    , announce_send_in_day
    , announce_latest_send_week
    , deleted
    , file_name
FROM {{ ref('stg_fms_rpt_period') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0
