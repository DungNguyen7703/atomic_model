/*
*--------------------------------------------------------------------*
* Program code: stg_fms_user_rpt_o
* Program name: Staging FMS.USER_RPT_O
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: yml append/None -> snapshot/ds_snpst_dt theo BRD.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(user_id)     AS user_id
    , HEX(tp_out_id) AS tp_out_id
FROM {{ source('source_fms', 'raw_user_rpt_o') }}