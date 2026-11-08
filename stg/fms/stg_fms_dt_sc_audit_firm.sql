/*
*--------------------------------------------------------------------*
* Program code: stg_fms_dt_sc_audit_firm
* Program name: Staging FMS.DT_SC_AUDIT_FIRM
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(dts_id)          AS dts_id
    , HEX(audit_firm_id) AS audit_firm_id
FROM {{ source('source_fms', 'raw_dt_sc_audit_firm') }}