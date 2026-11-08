/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_shareholder_ownership_change
* Program name: ODS SCMS.SC_FIRM_SHAREHOLDER_OWNERSHIP_CHANGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Doi ten cot theo stg moi (SCMS_UAT_schema).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , sc_firm_info_id
    , shareholder_id
    , capital_before
    , ratio_before
    , capital_after
    , ratio_after
    , transaction_type
    , document_number
    , effective_date
    , attachment_path
    , data_source
    , note
    , created_by
    , created_at
    , deleted
FROM {{ ref('stg_scms_sc_firm_shareholder_ownership_change') }}
WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1