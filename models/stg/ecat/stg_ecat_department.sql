/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_department
* Program name: Staging ECAT.DEPARTMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: them cot type.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(code AS string)                    AS code
    , CAST(name AS string)                    AS name
    , CAST(parent_id AS string)               AS parent_id
    , CAST(description AS string)             AS description
    , CAST(phone AS string)                   AS phone
    , CAST(email AS string)                   AS email
    , CAST(active AS int)                     AS active
    , CAST(active_reason AS string)           AS active_reason
    , CAST(deleted AS int)                    AS deleted
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(version AS int)                    AS version
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(old_id AS string)                  AS old_id
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(stable_id AS string)               AS stable_id
    , CAST(parent_version_id AS string)       AS parent_version_id
    , CAST(sort_order AS bigint)              AS sort_order
    , CAST(effective AS int)                  AS effective
    , CAST(type AS int)                       AS type
FROM {{ source('source_ecat', 'raw_department') }}