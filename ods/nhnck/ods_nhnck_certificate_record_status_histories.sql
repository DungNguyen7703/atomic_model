/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_certificate_record_status_histories
* Program name: ODS NHNCK.CERTIFICATE_RECORD_STATUS_HISTORIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , certificate_record_id
    , update_type
    , old_status
    , new_status
    , decision_id
    , reason
    , created_by
    , created_at
    , updated_at
    , updated_by
FROM {{ ref('stg_nhnck_certificate_record_status_histories') }}