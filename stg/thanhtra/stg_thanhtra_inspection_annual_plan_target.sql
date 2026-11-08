/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_inspection_annual_plan_target
* Program name: Staging THANHTRA.INSPECTION_ANNUAL_PLAN_TARGET
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[LLD atomic lld_THANHTRA_INSPECTION_ANNUAL_PLAN_TARGET.yaml] them cot implemented, actual_quarter (cuoi, sau deleted).
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                          AS id
    , CAST(inspection_annual_plan_id AS string) AS inspection_annual_plan_id
    , CAST(target_type AS string)               AS target_type
    , CAST(target_reference_id AS string)       AS target_reference_id
    , CAST(target_name AS string)               AS target_name
    , CAST(target_code AS string)               AS target_code
    , CAST(target_source AS string)             AS target_source
    , CAST(planned_quarter AS int)              AS planned_quarter
    , CAST(planned_content AS string)           AS planned_content
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(last_modified_at AS timestamp)       AS last_modified_at
    , CAST(created_by AS string)                AS created_by
    , CAST(last_modified_by AS string)          AS last_modified_by
    , CAST(version AS bigint)                   AS version
    , CAST(deleted AS int)                      AS deleted
    , CAST(implemented AS int)    AS implemented
    , CAST(actual_quarter AS int) AS actual_quarter
FROM {{ source('source_thanhtra', 'raw_inspection_annual_plan_target') }}