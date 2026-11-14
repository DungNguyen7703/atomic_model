/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_independent_audit_firm
* Program name: Staging ECAT.INDEPENDENT_AUDIT_FIRM
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
    CAST(id AS string)                      AS id
    , CAST(stable_id AS string)               AS stable_id
    , CAST(id_sync AS decimal(22,0))          AS id_sync
    , CAST(code AS string)                    AS code
    , CAST(parent_id AS decimal(22,0))        AS parent_id
    , CAST(parent_code AS string)             AS parent_code
    , CAST(name AS string)                    AS name
    , CAST(short_name AS string)              AS short_name
    , CAST(address AS string)                 AS address
    , CAST(tax_code AS string)                AS tax_code
    , CAST(effective AS string)               AS effective
    , CAST(issue_date AS timestamp)           AS issue_date
    , CAST(effective_date AS timestamp)       AS effective_date
    , CAST(end_date AS timestamp)             AS end_date
    , CAST(modified_date AS timestamp)        AS modified_date
    , CAST(created_date AS timestamp)         AS created_date
    , CAST(issue_document AS string)          AS issue_document
    , CAST(note AS string)                    AS note
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
FROM {{ source('source_ecat', 'raw_independent_audit_firm') }}