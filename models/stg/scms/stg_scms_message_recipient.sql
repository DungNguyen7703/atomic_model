/*
*--------------------------------------------------------------------*
* Program code: stg_scms_message_recipient
* Program name: Staging SCMS.MESSAGE_RECIPIENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)        AS id
    , CAST(recipient_id AS bigint) AS recipient_id
    , CAST(message_id AS bigint) AS message_id
FROM {{ source('source_scms', 'raw_message_recipient') }}