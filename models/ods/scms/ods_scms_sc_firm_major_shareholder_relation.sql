/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_major_shareholder_relation
* Program name: ODS SCMS.SC_FIRM_MAJOR_SHAREHOLDER_RELATION
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
    , individual
    , shareholder_id
    , sc_firm_info_id
    , address
    , phone
    , email
    , note
    , full_name
    , relationship
    , relation_start_date
    , issue_date
    , last_modified_at
    , large_shareholder_date
    , relation_end_date
    , created_at
    , issue_place
    , nationality_id
    , identification_number
    , shares_count
    , ownership_ratio
    , contributed_capital
    , deleted
    , created_by
    , last_modified_by
FROM {{ ref('stg_scms_sc_firm_major_shareholder_relation') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')