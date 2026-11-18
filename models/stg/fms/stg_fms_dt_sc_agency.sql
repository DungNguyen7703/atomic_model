/*
*--------------------------------------------------------------------*
* Program code: stg_fms_dt_sc_agency
* Program name: Staging FMS.DT_SC_AGENCY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: yml append/None -> snapshot/ds_snpst_dt theo BRD.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(dts_id)                          AS dts_id
    , HEX(agen_id)                       AS agen_id
    , CAST(system_object_type AS bigint) AS system_object_type
FROM {{ source('source_fms', 'raw_dt_sc_agency') }}