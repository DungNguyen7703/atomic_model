/*
*--------------------------------------------------------------------*
* Program code: stg_fms_user_rpt_i
* Program name: Staging FMS.USER_RPT_I
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(user_id)  AS user_id
    , HEX(rpt_id) AS rpt_id
FROM {{ source('source_fms', 'raw_user_rpt_i') }}