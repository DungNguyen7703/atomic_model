/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rpt_pd_sht
* Program name: Staging FMS.RPT_PD_SHT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(sht_id)                   AS sht_id
    , HEX(rpt_pd_id)              AS rpt_pd_id
    , CAST(date_created AS date)  AS date_created
    , CAST(created_by AS string)  AS created_by
    , CAST(date_modified AS date) AS date_modified
    , CAST(modify_by AS string)   AS modify_by
FROM {{ source('source_fms', 'raw_rpt_pd_sht') }}