/*
*--------------------------------------------------------------------*
* Program code: stg_knt_msg_packet
* Program name: Staging KNT.MSG_PACKET
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                     AS id
    , CAST(packet_code AS string)         AS packet_code
    , CAST(type AS int)                   AS type
    , CAST(sender_unit AS int)            AS sender_unit
    , CAST(receiver_unit AS int)          AS receiver_unit
    , CAST(sent_by AS string)             AS sent_by
    , CAST(status AS int)                 AS status
    , CAST(content AS string)             AS content
    , CAST(description AS string)         AS description
    , CAST(sent_at AS date)               AS sent_at
    , CAST(version AS string)             AS version
    , CAST(sender_code AS string)         AS sender_code
    , CAST(sender_name AS string)         AS sender_name
    , CAST(receiver_code AS string)       AS receiver_code
    , CAST(receiver_name AS string)       AS receiver_name
    , CAST(tran_code AS string)           AS tran_code
    , CAST(msg_id AS string)              AS msg_id
    , CAST(msg_ref_id AS string)          AS msg_ref_id
    , CAST(link_id AS string)             AS link_id
    , CAST(original_code AS string)       AS original_code
    , CAST(original_name AS string)       AS original_name
    , CAST(original_date AS string)       AS original_date
    , CAST(error_code AS string)          AS error_code
    , CAST(error_desc AS string)          AS error_desc
    , CAST(spare1 AS string)              AS spare1
    , CAST(spare2 AS string)              AS spare2
    , CAST(spare3 AS string)              AS spare3
    , CAST(parent_id AS int)              AS parent_id
    , CAST(tax_code AS string)            AS tax_code
    , CAST(representative_name AS string) AS representative_name
    , CAST(created_by AS string)          AS created_by
    , CAST(time_start AS date)            AS time_start
    , CAST(time_end AS date)              AS time_end
    , CAST(is_sent_tct AS int)            AS is_sent_tct
    , CAST(is_sent_mof AS int)            AS is_sent_mof
    , CAST(send_tct_count AS int)         AS send_tct_count
    , CAST(send_mof_count AS int)         AS send_mof_count
    , CAST(msg_error AS string)           AS msg_error
    , CAST(received_at AS date)           AS received_at
    , CAST(status_mof AS int)             AS status_mof
    , CAST(deleted AS string)             AS deleted
FROM {{ source('source_knt', 'raw_msg_packet') }}