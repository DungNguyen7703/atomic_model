/*
*--------------------------------------------------------------------*
* Program code: ods_fms_fund_tl_pro
* Program name: ODS FMS.FUND_TL_PRO
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    fund_id
    , tlpr_id
FROM {{ ref('stg_fms_fund_tl_pro') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')