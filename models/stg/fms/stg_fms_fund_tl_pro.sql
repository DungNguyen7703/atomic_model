/*
*--------------------------------------------------------------------*
* Program code: stg_fms_fund_tl_pro
* Program name: Staging FMS.FUND_TL_PRO
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(fund_id)   AS fund_id
    , HEX(tlpr_id) AS tlpr_id
FROM {{ source('source_fms', 'raw_fund_tl_pro') }}