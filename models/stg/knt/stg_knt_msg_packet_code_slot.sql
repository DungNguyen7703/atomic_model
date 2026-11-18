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
* 2026-11-08		tuan.nguyenvanb		Dong bo kieu theo dictionary Oracle KNT (query ket qua 2026-11-08, quy tac map cua DDL prod; CHUA khao sat du lieu): kieu int sang bigint (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(slot_key AS string)   AS slot_key
    , CAST(slot_count AS bigint) AS slot_count
FROM {{ source('source_knt', 'raw_msg_packet_code_slot') }}