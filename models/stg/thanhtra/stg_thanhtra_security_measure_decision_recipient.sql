/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_security_measure_decision_recipient
* Program name: Staging THANHTRA.SECURITY_MEASURE_DECISION_RECIPIENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (3 cot); them cot push_status, push_error, fms_event_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(security_measure_decision_id AS string) AS security_measure_decision_id
    , CAST(recipient_type AS string)               AS recipient_type
    , CAST(recipient_name AS string)               AS recipient_name
    , CAST(recipient_reference_id AS string)       AS recipient_reference_id
    , CAST(sent_date AS date)                      AS sent_date
    , CAST(confirmation_status AS string)          AS confirmation_status
    , CAST(confirmed_at AS timestamp)              AS confirmed_at
    , CAST(confirmed_by AS string)                 AS confirmed_by
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(last_modified_at AS timestamp)          AS last_modified_at
    , CAST(created_by AS string)                   AS created_by
    , CAST(last_modified_by AS string)             AS last_modified_by
    , CAST(version AS bigint)                      AS version
    , CAST(deleted AS int)                         AS deleted
    , CAST(push_status AS string)                  AS push_status
    , CAST(push_error AS string)                   AS push_error
    , CAST(fms_event_id AS string)                 AS fms_event_id
FROM {{ source('source_thanhtra', 'raw_security_measure_decision_recipient') }}