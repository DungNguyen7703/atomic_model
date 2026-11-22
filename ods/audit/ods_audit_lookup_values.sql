/*
*--------------------------------------------------------------------*
* Program code: ods_audit_lookup_values
* Program name: ODS AUDIT.LOOKUP_VALUES
* Created by: ngoc.pham
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		ngoc.pham		[MOI] Bo sung ODS theo brd_AUDIT.yaml (in_scope, data_change_mode Update -> Snapshot); cot theo DDL Staging (chua co DDL ODS)
*--------------------------------------------------------------------*
*/

SELECT
    id
    , lookup_group
    , lookup_cd
    , lookup_value_vn
    , lookup_value_en
    , display_order
    , description
    , active_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , sync_flg
    , delete_flg
    , system_cd
    , lookup_parent_id
FROM {{ ref('stg_audit_lookup_values') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
