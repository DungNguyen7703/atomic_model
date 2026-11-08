/*
*--------------------------------------------------------------------*
* Program code: stg_fms_user_rpt_o
* Program name: Staging FMS.USER_RPT_O
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(user_id)     AS user_id
    , HEX(tp_out_id) AS tp_out_id
FROM {{ source('source_fms', 'raw_user_rpt_o') }}