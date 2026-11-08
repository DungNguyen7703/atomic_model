/*
*--------------------------------------------------------------------*
* Program code: stg_knt_data_reconciliation_outbound
* Program name: Staging KNT.DATA_RECONCILIATION_OUTBOUND
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
    , CAST(reconciliation_date AS date)   AS reconciliation_date
    , CAST(msg_packet_id AS int)          AS msg_packet_id
    , CAST(packet_code AS string)         AS packet_code
    , CAST(msg_id AS string)              AS msg_id
    , CAST(tran_code AS string)           AS tran_code
    , CAST(total_packets AS int)          AS total_packets
    , CAST(total_records AS int)          AS total_records
    , CAST(status AS int)                 AS status
    , CAST(push_format AS string)         AS push_format
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
FROM {{ source('source_knt', 'raw_data_reconciliation_outbound') }}