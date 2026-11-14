/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_gms_ids_state_capital
* Program name: Staging ECAT.GMS_IDS_STATE_CAPITAL
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu decimal(38,10) sang bigint (1 cot); kieu decimal(38,10) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(company_profile_id AS string)         AS company_profile_id
    , CAST(company_profile_version_id AS string) AS company_profile_version_id
    , CAST(company_profile_stable_id AS string)  AS company_profile_stable_id
    , CAST(state_rep_name_vi AS string)          AS state_rep_name_vi
    , CAST(state_rep_name_en AS string)          AS state_rep_name_en
    , CAST(state_owner_org_vi AS string)         AS state_owner_org_vi
    , CAST(state_owner_org_en AS string)         AS state_owner_org_en
    , CAST(owned_share_qty AS bigint)            AS owned_share_qty
    , CAST(ownership_ratio AS decimal(38,10))    AS ownership_ratio
    , CAST(id_sync AS string)                    AS id_sync
    , CAST(is_sync AS int)                       AS is_sync
    , CAST(deleted AS int)                       AS deleted
    , CAST(deleted_reason AS string)             AS deleted_reason
    , CAST(version AS int)                       AS version
    , CAST(effective_start_date AS timestamp)    AS effective_start_date
    , CAST(effective_end_date AS timestamp)      AS effective_end_date
    , CAST(old_id AS string)                     AS old_id
    , CAST(stable_id AS string)                  AS stable_id
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(updated_at AS timestamp)              AS updated_at
    , CAST(created_by_id AS string)              AS created_by_id
    , CAST(created_by_name AS string)            AS created_by_name
    , CAST(updated_by_id AS string)              AS updated_by_id
    , CAST(updated_by_name AS string)            AS updated_by_name
FROM {{ source('source_ecat', 'raw_gms_ids_state_capital') }}