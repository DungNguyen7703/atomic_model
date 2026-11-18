/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_petition_target
* Program name: Staging THANHTRA.PETITION_TARGET
* Created by: tuan.nguyenvanb
* Created date: 2026-10-08
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-08		tuan.nguyenvanb		[MOI] Bo sung STG theo THANHTRA_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                  AS id
    , CAST(petition_id AS string)         AS petition_id
    , CAST(target_type AS string)         AS target_type
    , CAST(target_reference_id AS string) AS target_reference_id
    , CAST(target_name AS string)         AS target_name
    , CAST(sort_order AS int)             AS sort_order
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)          AS created_by
    , CAST(last_modified_by AS string)    AS last_modified_by
    , CAST(version AS bigint)             AS version
    , CAST(deleted AS int)                AS deleted
FROM {{ source('source_thanhtra', 'raw_petition_target') }}