/*
*--------------------------------------------------------------------*
* Program code: stg_scms_bank_history
* Program name: Staging SCMS.BANK_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: yml chuyen snapshot/ds_snpst_dt sang append/performed_at.
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot); WHERE loc theo cot performed_at trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: effective_date; int sang bigint: id, bank_id, performed_by.
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (performed_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(performed_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(bank_id AS bigint)                AS bank_id
    , CAST(performed_at AS timestamp)     AS performed_at
    , CAST(matter_code AS string)         AS matter_code
    , CAST(event_type_name AS string)     AS event_type_name
    , CAST(content_before AS string)      AS content_before
    , CAST(content_after AS string)       AS content_after
    , CAST(document_number AS string)     AS document_number
    , CAST(effective_date AS date)   AS effective_date
    , CAST(document_file_name AS string)  AS document_file_name
    , CAST(document_file_path AS string)  AS document_file_path
    , CAST(performed_by AS bigint)           AS performed_by
    , CAST(performer_name AS string)      AS performer_name
    , CAST(snapshot_after_json AS string) AS snapshot_after_json
    , CAST(matter_id AS decimal(19,0))    AS matter_id
FROM {{ source('source_scms', 'raw_bank_history') }}
WHERE date_format(performed_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(performed_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1