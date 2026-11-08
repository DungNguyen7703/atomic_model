/*
*--------------------------------------------------------------------*
* Program code: stg_scms_member_report_history
* Program name: Staging SCMS.MEMBER_REPORT_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (7 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: WHERE loc theo cot created_at trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (created_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(created_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                   AS id
    , CAST(member_report_id AS bigint)     AS member_report_id
    , CAST(sc_firm_info_id AS bigint)      AS sc_firm_info_id
    , CAST(form_report_id AS bigint)       AS form_report_id
    , CAST(form_periodic_report_id AS bigint) AS form_periodic_report_id
    , CAST(user_id AS bigint)              AS user_id
    , CAST(description AS string)          AS description
    , CAST(reason AS string)               AS reason
    , CAST(submission_time AS string)      AS submission_time
    , CAST(resubmission_reason AS string)  AS resubmission_reason
    , CAST(attachment_path AS string)      AS attachment_path
    , CAST(data_date AS timestamp)         AS data_date
    , CAST(sent_at AS timestamp)           AS sent_at
    , CAST(created_at AS timestamp)        AS created_at
    , CAST(record_status AS int)           AS record_status
    , CAST(version AS int)                 AS version
    , CAST(report_cancelled AS int)        AS report_cancelled
    , CAST(old_data AS string)             AS old_data
    , CAST(new_data AS string)             AS new_data
    , CAST(action AS string)               AS action
    , CAST(ip_address AS string)           AS ip_address
    , CAST(performed_at AS timestamp)      AS performed_at
    , CAST(performed_by AS bigint)         AS performed_by
    , CAST(performer_name AS string)       AS performer_name
FROM {{ source('source_scms', 'raw_member_report_history') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1