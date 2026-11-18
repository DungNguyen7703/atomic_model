/*
*--------------------------------------------------------------------*
* Program code: stg_fms_sec_fund_manager
* Program name: Staging FMS.SEC_FUND_MANAGER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(sec_id)    AS sec_id
    , HEX(tlpr_id) AS tlpr_id
FROM {{ source('source_fms', 'raw_sec_fund_manager') }}