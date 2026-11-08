/*
*--------------------------------------------------------------------*
* Program code: stg_scms_message
* Program name: Staging SCMS.MESSAGE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (2 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: int sang bigint: reply_to_message_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                    AS id
    , CAST(attachment_path AS string)       AS attachment_path
    , CAST(send_by_email AS int)            AS send_by_email
    , CAST(sent_at AS timestamp)            AS sent_at
    , CAST(sender_id AS bigint)             AS sender_id
    , CAST(content AS string)               AS content
    , CAST(title AS string)                 AS title
    , CAST(reply_to_message_id AS bigint)      AS reply_to_message_id
    , CAST(recipient_unit_labels AS string) AS recipient_unit_labels
FROM {{ source('source_scms', 'raw_message') }}