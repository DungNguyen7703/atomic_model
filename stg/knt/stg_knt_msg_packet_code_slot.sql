/*
*--------------------------------------------------------------------*
* Program code: stg_knt_msg_packet_code_slot
* Program name: Staging KNT.MSG_PACKET_CODE_SLOT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(slot_key AS string) AS slot_key
    , CAST(slot_count AS int)  AS slot_count
FROM {{ source('source_knt', 'raw_msg_packet_code_slot') }}