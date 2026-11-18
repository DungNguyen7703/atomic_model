/*
*--------------------------------------------------------------------*
* Program code: ods_scms_lnk_sc_firm_service
* Program name: ODS SCMS.LNK_SC_FIRM_SERVICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Dong bo day du cot theo stg moi.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , sc_firm_info_id
    , service_id
    , license_number
    , license_date
    , record_status
    , created_at
    , start_date
    , end_date
    , approval_file
FROM {{ ref('stg_scms_lnk_sc_firm_service') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') 
  AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1