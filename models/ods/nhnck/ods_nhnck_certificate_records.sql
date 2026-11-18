/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_certificate_records
* Program name: ODS NHNCK.CERTIFICATE_RECORDS
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
    , certificate_id
    , professional_id
    , issue_decision_id
    , revocation_decision_id
    , certificate_number
    , issue_date
    , revocation_date
    , revocation_reason
    , status
    , description
    , created_at
    , created_by
    , allow_reissue
    , professional_full_name
    , updated_at
    , process_status
    , cer_path
    , cancellation_decision_id
    , conversion_status
    , updated_by
FROM {{ ref('stg_nhnck_certificate_records') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')