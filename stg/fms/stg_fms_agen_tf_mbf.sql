/*
*--------------------------------------------------------------------*
* Program code: stg_fms_agen_tf_mbf
* Program name: Staging FMS.AGEN_TF_MBF
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(agen_id)  AS agen_id
    , HEX(tmb_id) AS tmb_id
FROM {{ source('source_fms', 'raw_agen_tf_mbf') }}