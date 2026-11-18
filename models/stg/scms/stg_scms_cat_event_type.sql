/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_event_type
* Program name: Staging SCMS.CAT_EVENT_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (7 cot); kieu int sang decimal(19,0) (1 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (2 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: effective_date, expiry_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                       AS id
    , CAST(event_type_code AS string)          AS event_type_code
    , CAST(event_type_name AS string)          AS event_type_name
    , CAST(note AS string)                     AS note
    , CAST(created_by AS bigint)               AS created_by
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(record_status AS int)               AS record_status
    , CAST(requires_license AS int)            AS requires_license
    , CAST(target_entity AS string)            AS target_entity
    , CAST(requires_disclosure AS int)         AS requires_disclosure
    , CAST(obligation_type AS bigint)          AS obligation_type
    , CAST(event_group_id AS bigint)           AS event_group_id
    , CAST(cycle AS bigint)                    AS cycle
    , CAST(frequency AS bigint)                AS frequency
    , CAST(cutoff_date AS string)              AS cutoff_date
    , CAST(submission_method AS bigint)        AS submission_method
    , CAST(effective_date AS date)        AS effective_date
    , CAST(expiry_date AS date)           AS expiry_date
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(updated_by AS decimal(19,0))        AS updated_by
    , CAST(event_category AS int)              AS event_category
    , CAST(deadline_calculation_method AS int) AS deadline_calculation_method
    , CAST(extended_data AS string)            AS extended_data
FROM {{ source('source_scms', 'raw_cat_event_type') }}