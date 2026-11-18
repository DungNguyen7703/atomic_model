/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_examination_team_target
* Program name: Staging THANHTRA.EXAMINATION_TEAM_TARGET
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[LLD atomic lld_THANHTRA_EXAMINATION_TEAM_TARGET.yaml] Them cot start_date, end_date (cuoi danh sach cot nghiep vu)
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(examination_team_id AS string)          AS examination_team_id
    , CAST(target_type AS string)                  AS target_type
    , CAST(target_reference_id AS string)          AS target_reference_id
    , CAST(target_name AS string)                  AS target_name
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(last_modified_at AS timestamp)          AS last_modified_at
    , CAST(created_by AS string)                   AS created_by
    , CAST(last_modified_by AS string)             AS last_modified_by
    , CAST(version AS bigint)                      AS version
    , CAST(deleted AS int)                         AS deleted
    , CAST(account_number AS string)               AS account_number
    , CAST(securities_company_name AS string)      AS securities_company_name
    , CAST(address AS string)                      AS address
    , CAST(citizen_id AS string)                   AS citizen_id
    , CAST(business_registration_number AS string) AS business_registration_number
    , CAST(legal_rep_name AS string)               AS legal_rep_name
    , CAST(legal_rep_citizen_id AS string)         AS legal_rep_citizen_id
    , CAST(start_date AS date)                     AS start_date
    , CAST(end_date AS date)                       AS end_date
FROM {{ source('source_thanhtra', 'raw_examination_team_target') }}