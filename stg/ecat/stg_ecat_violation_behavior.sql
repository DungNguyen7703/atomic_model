/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_violation_behavior
* Program name: Staging ECAT.VIOLATION_BEHAVIOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang bigint (2 cot); them cot id_sync.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(code AS string)                    AS code
    , CAST(name AS string)                    AS name
    , CAST(description AS string)             AS description
    , CAST(clause_reference AS string)        AS clause_reference
    , CAST(legal_document AS string)          AS legal_document
    , CAST(min_fine_amount AS bigint)         AS min_fine_amount
    , CAST(max_fine_amount AS bigint)         AS max_fine_amount
    , CAST(remediation_measure AS string)     AS remediation_measure
    , CAST(status AS int)                     AS status
    , CAST(note AS string)                    AS note
    , CAST(active AS int)                     AS active
    , CAST(active_reason AS string)           AS active_reason
    , CAST(deleted AS int)                    AS deleted
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(version AS int)                    AS version
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(old_id AS string)                  AS old_id
    , CAST(stable_id AS string)               AS stable_id
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(id_sync AS string)                 AS id_sync
FROM {{ source('source_ecat', 'raw_violation_behavior') }}