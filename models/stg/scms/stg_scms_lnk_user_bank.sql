/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_user_bank
* Program name: Staging SCMS.LNK_USER_BANK
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: int sang bigint: id, user_id, bank_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)      AS id
    , CAST(user_id AS bigint) AS user_id
    , CAST(bank_id AS bigint) AS bank_id
FROM {{ source('source_scms', 'raw_lnk_user_bank') }}