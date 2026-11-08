/*
*--------------------------------------------------------------------*
* Program code: ods_fims_ward_new
* Program name: ODS FIMS.WARD_NEW
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung ODS theo LLD FIMS (INVESTOR_IP_Postal_Address).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , code
    , namevn
    , nameen
    , provincecode
    , category
    , status
    , deleted
    , ecatalog_id
    , datecreated
    , createdby
FROM {{ ref('stg_fims_ward_new') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
and deleted = 0