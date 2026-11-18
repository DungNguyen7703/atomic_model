/*
*--------------------------------------------------------------------*
* Program code: stg_fms_fg_business
* Program name: Staging FMS.FG_BUSINESS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(fr_bch_id) AS fr_bch_id
    , HEX(bu_id)   AS bu_id
FROM {{ source('source_fms', 'raw_fg_business') }}