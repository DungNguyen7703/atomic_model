/*
*--------------------------------------------------------------------*
* Program code: ods_fms_fud_ag_agt
* Program name: ODS FMS.FUD_AG_AGT
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-14		claude				Khởi tạo — nguồn cho Atomic fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship
*--------------------------------------------------------------------*
*/

SELECT
    id
    , fud_id
    , ag_ty_id
    , agen_id
    , agen_id_parent
    , system_object_type
FROM {{ ref('stg_fms_fud_ag_agt') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
