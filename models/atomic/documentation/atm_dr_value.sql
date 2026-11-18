/*
*--------------------------------------------------------------------*
* Program code: atm_dr_value
* Program name: Atomic Dynamic Report Value - Multi Source
* Created by: claude (sync)
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		claude (sync)		Tạo mới dạng multi-source (UNION ALL các model ephemeral theo nguồn), giống atm_ip_alternative_identification.
*                                       Nhánh: FMS_ITEM_VALUE. Nhánh: FMS_ITEM_VALUE, SCMS_ITEM_VALUE.
*--------------------------------------------------------------------*
* 2026-11-12		claude (sync)		Đổi upsert -> incremental_rebase/merge (delta theo data_dt, không soft-delete vì nguồn không xoá mềm).
*                                       Merge = ghi đè theo dr_val_id (SCD1), không có ds_rcrd_st -> mart khai thác trực tiếp.
*--------------------------------------------------------------------*
*/
SELECT * FROM {{ ref('atm_dr_value_fms_item_value') }}
UNION ALL
SELECT * FROM {{ ref('atm_dr_value_scms_item_value') }}
