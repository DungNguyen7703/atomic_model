/*
*--------------------------------------------------------------------*
* Program code: ods_fms_offering_plan
* Program name: ODS FMS.OFFERING_PLAN
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-21		tuan.nguyenvanb		[LLD atomic lld_FMS_OFFERING_PLAN.yaml approved] Dung lai ODS cho FMS.OFFERING_PLAN (nguon STG stg_fms_offering_plan) phuc vu atomic fmc_securities_offering_plan.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , offering_id
    , sort_order
    , target_audience
    , method_code
    , quantity_cb
    , price_cb
    , value_cb
    , people_count
    , audience_description
    , swap_purpose
    , actual_quantity_cb
    , actual_price_cb
    , actual_value_cb
    , actual_people_count
    , actual_audience_description
    , actual_swap_purpose
    , foreign_investor_count
    , issuance_value_foreign
FROM {{ ref('stg_fms_offering_plan') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
