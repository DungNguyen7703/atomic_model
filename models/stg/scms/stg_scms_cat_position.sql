/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_position
* Program name: Staging SCMS.CAT_POSITION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)             AS id
    , CAST(position_group AS string) AS position_group
    , CAST(position_code AS string)  AS position_code
    , CAST(position_name AS string)  AS position_name
    , CAST(note AS string)           AS note
    , CAST(created_by AS bigint)     AS created_by
    , CAST(created_at AS timestamp)  AS created_at
    , CAST(record_status AS int)     AS record_status
    , CAST(representative AS int)    AS representative
    , CAST(board_member AS int)      AS board_member
    , CAST(branch_director AS int)   AS branch_director
    , CAST(ecatalog_id AS string)    AS ecatalog_id
FROM {{ source('source_scms', 'raw_cat_position') }}