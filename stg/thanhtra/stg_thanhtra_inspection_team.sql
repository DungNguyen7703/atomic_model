/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_inspection_team
* Program name: Staging THANHTRA.INSPECTION_TEAM
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[LLD atomic lld_THANHTRA_INSPECTION_TEAM.yaml] them cot criminal_transfer, criminal_transfer_note (cuoi, sau verification_minutes_sign_date).
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(code AS string)                         AS code
    , CAST(inspection_annual_plan_id AS string)    AS inspection_annual_plan_id
    , CAST(plan_year AS int)                       AS plan_year
    , CAST(form_type AS string)                    AS form_type
    , CAST(start_date AS date)                     AS start_date
    , CAST(end_date AS date)                       AS end_date
    , CAST(duration_days AS int)                   AS duration_days
    , CAST(decision_number AS string)              AS decision_number
    , CAST(decision_date AS date)                  AS decision_date
    , CAST(decision_name AS string)                AS decision_name
    , CAST(announcement_date AS date)              AS announcement_date
    , CAST(content AS string)                      AS content
    , CAST(inspection_period_from AS date)         AS inspection_period_from
    , CAST(inspection_period_to AS date)           AS inspection_period_to
    , CAST(anti_money_laundering AS int)           AS anti_money_laundering
    , CAST(abnormal_transaction_check AS int)      AS abnormal_transaction_check
    , CAST(note AS string)                         AS note
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(last_modified_at AS timestamp)          AS last_modified_at
    , CAST(created_by AS string)                   AS created_by
    , CAST(last_modified_by AS string)             AS last_modified_by
    , CAST(version AS bigint)                      AS version
    , CAST(deleted AS int)                         AS deleted
    , CAST(verification_minutes_sign_date AS date) AS verification_minutes_sign_date
    , CAST(criminal_transfer AS int)         AS criminal_transfer
    , CAST(criminal_transfer_note AS string) AS criminal_transfer_note
FROM {{ source('source_thanhtra', 'raw_inspection_team') }}