/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_security_measure_decision
* Program name: Staging THANHTRA.SECURITY_MEASURE_DECISION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(decision_number AS string)  AS decision_number
    , CAST(decision_date AS date)      AS decision_date
    , CAST(measure_type AS string)     AS measure_type
    , CAST(effective_date AS date)     AS effective_date
    , CAST(duration_months AS int)     AS duration_months
    , CAST(signer_name AS string)      AS signer_name
    , CAST(summary AS string)          AS summary
    , CAST(sent_status AS string)      AS sent_status
    , CAST(sent_at AS timestamp)       AS sent_at
    , CAST(sent_by AS string)          AS sent_by
    , CAST(note AS string)             AS note
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)       AS created_by
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(version AS bigint)          AS version
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_thanhtra', 'raw_security_measure_decision') }}