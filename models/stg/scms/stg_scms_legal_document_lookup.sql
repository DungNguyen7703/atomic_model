/*
*--------------------------------------------------------------------*
* Program code: stg_scms_legal_document_lookup
* Program name: Staging SCMS.LEGAL_DOCUMENT_LOOKUP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (3 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: WHERE loc theo cot created_at trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (created_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(created_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(document_number AS string)   AS document_number
    , CAST(content_summary AS string)   AS content_summary
    , CAST(attachment_path AS string)   AS attachment_path
    , CAST(created_by AS bigint)        AS created_by
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(issued_date AS timestamp)    AS issued_date
    , CAST(record_status AS bigint)     AS record_status
    , CAST(effective_date AS timestamp) AS effective_date
FROM {{ source('source_scms', 'raw_legal_document_lookup') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1