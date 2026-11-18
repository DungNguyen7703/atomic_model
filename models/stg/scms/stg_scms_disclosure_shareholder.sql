/*
*--------------------------------------------------------------------*
* Program code: stg_scms_disclosure_shareholder
* Program name: Staging SCMS.DISCLOSURE_SHAREHOLDER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (7 cot); doi thu tu cot.
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu string sang binary (1 cot); doi thu tu cot.
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (created_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(created_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(sc_firm_info_id AS bigint)        AS sc_firm_info_id
    , CAST(transaction_type_id AS bigint)    AS transaction_type_id
    , CAST(disclosure_date AS timestamp)     AS disclosure_date
    , CAST(content AS string)                AS content
    , CAST(created_by AS bigint)             AS created_by
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(record_status AS int)             AS record_status
    , CAST(title AS string)                  AS title
    , CAST(summary AS string)                AS summary
    , CAST(sent_at AS timestamp)             AS sent_at
    , CAST(legacy_filename AS string)        AS legacy_filename
    , CAST(legacy_filedata AS binary)        AS legacy_filedata
    , CAST(legacy_rowtext AS string)         AS legacy_rowtext
    , CAST(event_date AS timestamp)          AS event_date
    , CAST(disclosure_deadline AS timestamp) AS disclosure_deadline
    , CAST(disclosure_person_name AS string) AS disclosure_person_name
    , CAST(sender_id AS bigint)              AS sender_id
    , CAST(note AS string)                   AS note
    , CAST(eform_data AS string)             AS eform_data
    , CAST(late_days AS bigint)              AS late_days
    , CAST(updated_at AS timestamp)          AS updated_at
    , CAST(updated_by AS bigint)             AS updated_by
    , CAST(import_file_path AS string)       AS import_file_path
    , CAST(import_file_name AS string)       AS import_file_name
    , CAST(import_data AS string)            AS import_data
    , CAST(import_bm_id AS decimal(19,0))    AS import_bm_id
    , CAST(attachment_path AS string)        AS attachment_path
FROM {{ source('source_scms', 'raw_disclosure_shareholder') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1