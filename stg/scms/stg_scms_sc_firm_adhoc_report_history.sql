/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_adhoc_report_history
* Program name: Staging SCMS.SC_FIRM_ADHOC_REPORT_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (3 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: WHERE loc theo cot performed_at trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (performed_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(performed_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)              AS id
    , CAST(report_id AS bigint)       AS report_id
    , CAST(data_file_path AS string)  AS data_file_path
    , CAST(note AS string)            AS note
    , CAST(performer_name AS string)  AS performer_name
    , CAST(action AS string)          AS action
    , CAST(performed_at AS timestamp) AS performed_at
    , CAST(record_status AS bigint)   AS record_status
FROM {{ source('source_scms', 'raw_sc_firm_adhoc_report_history') }}
WHERE date_format(performed_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(performed_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1