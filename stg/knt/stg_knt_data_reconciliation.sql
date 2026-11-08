/*
*--------------------------------------------------------------------*
* Program code: stg_knt_data_reconciliation
* Program name: Staging KNT.DATA_RECONCILIATION
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
    , CAST(source AS string)              AS source
    , CAST(record_count AS int)           AS record_count
    , CAST(total_packets AS int)          AS total_packets
    , CAST(msg_id AS string)              AS msg_id
    , CAST(msg_ref_id AS string)          AS msg_ref_id
    , CAST(tran_code AS string)           AS tran_code
    , CAST(sender_code AS string)         AS sender_code
    , CAST(receiver_code AS string)       AS receiver_code
    , CAST(status AS int)                 AS status
    , CAST(error_message AS string)       AS error_message
    , CAST(raw_json AS string)            AS raw_json
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
FROM {{ source('source_knt', 'raw_data_reconciliation') }}