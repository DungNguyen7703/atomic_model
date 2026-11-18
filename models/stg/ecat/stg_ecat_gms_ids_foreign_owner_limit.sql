/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_gms_ids_foreign_owner_limit
* Program name: Staging ECAT.GMS_IDS_FOREIGN_OWNER_LIMIT
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu decimal(38,10) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(company_profile_id AS string)         AS company_profile_id
    , CAST(company_profile_version_id AS string) AS company_profile_version_id
    , CAST(company_profile_stable_id AS string)  AS company_profile_stable_id
    , CAST(max_owner_rate AS decimal(10,4))      AS max_owner_rate
    , CAST(from_date AS timestamp)               AS from_date
    , CAST(to_date AS timestamp)                 AS to_date
    , CAST(id_sync AS string)                    AS id_sync
    , CAST(sync_flag AS int)                     AS sync_flag
    , CAST(created_by AS string)                 AS created_by
    , CAST(created_date AS timestamp)            AS created_date
    , CAST(updated_by AS string)                 AS updated_by
    , CAST(updated_date AS timestamp)            AS updated_date
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
FROM {{ source('source_ecat', 'raw_gms_ids_foreign_owner_limit') }}