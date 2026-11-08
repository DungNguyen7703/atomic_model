/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_violation_case
* Program name: Staging THANHTRA.VIOLATION_CASE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot); them cot report_classification.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(code AS string)                    AS code
    , CAST(name AS string)                    AS name
    , CAST(source_category AS string)         AS source_category
    , CAST(source_unit_id AS string)          AS source_unit_id
    , CAST(source_unit_name AS string)        AS source_unit_name
    , CAST(inspection_team_id AS string)      AS inspection_team_id
    , CAST(examination_team_id AS string)     AS examination_team_id
    , CAST(assigned_officer_id AS string)     AS assigned_officer_id
    , CAST(assigned_officer_name AS string)   AS assigned_officer_name
    , CAST(supervising_leader_id AS string)   AS supervising_leader_id
    , CAST(supervising_leader_name AS string) AS supervising_leader_name
    , CAST(status AS string)                  AS status
    , CAST(bond_issuer_code AS string)        AS bond_issuer_code
    , CAST(market_type AS string)             AS market_type
    , CAST(bond_code AS string)               AS bond_code
    , CAST(processing_progress AS string)     AS processing_progress
    , CAST(note AS string)                    AS note
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(last_modified_at AS timestamp)     AS last_modified_at
    , CAST(created_by AS string)              AS created_by
    , CAST(last_modified_by AS string)        AS last_modified_by
    , CAST(version AS bigint)                 AS version
    , CAST(deleted AS int)                    AS deleted
    , CAST(report_classification AS string)   AS report_classification
FROM {{ source('source_thanhtra', 'raw_violation_case') }}