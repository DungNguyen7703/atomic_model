/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_shareholder_representative
* Program name: ODS SCMS.SC_FIRM_SHAREHOLDER_REPRESENTATIVE
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
    , sc_firm_shareholder_id
    , representative_name
    , position
    , id_number
    , issue_date
    , issue_place
    , shares_count
    , ownership_ratio
    , attachment_path
    , note
    , created_by
    , created_at
    , last_modified_by
    , last_modified_at
    , record_status
    , deleted
FROM {{ ref('stg_scms_sc_firm_shareholder_representative') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')