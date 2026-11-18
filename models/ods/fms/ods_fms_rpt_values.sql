/*
*--------------------------------------------------------------------*
* Program code: ods_fms_rpt_values
* Program name: ODS FMS.RPT_VALUES
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-14		claude				Khởi tạo — nguồn cho Atomic fmr_value
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , tgt_id
    , meb_id
    , sheet_id
    , rpt_id
    , values
    , prd_id
    , dynamic_value
    , acc_values
    , period_type
    , format_data_type
    , code
    , bkm_id
    , fnd_id
    , fr_br_id
    , sec_id
    , record_type
    , period_value
    , year_value
    , row_dynamic
FROM {{ ref('stg_fms_rpt_values') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
