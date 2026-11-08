/*
*--------------------------------------------------------------------*
* Program code: stg_fms_sec_business
* Program name: Staging FMS.SEC_BUSINESS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(sec_id)  AS sec_id
    , HEX(bu_id) AS bu_id
FROM {{ source('source_fms', 'raw_sec_business') }}