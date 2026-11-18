/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_petition
* Program name: ODS THANHTRA.PETITION
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
    , code
    , received_date
    , forwarding_unit
    , sender_name
    , sender_address
    , content
    , petition_category
    , related_to_corporate_bond
    , eligible_for_processing
    , within_jurisdiction
    , assigned_officer_id
    , assigned_officer_name
    , duplicate_type
    , original_petition_id
    , submission_number
    , transferred_authority
    , internal_transfer_unit_id
    , internal_transfer_unit_name
    , archived
    , guidance_document_number
    , guidance_document_date
    , status
    , note
    , end_date
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , target_type
    , target_reference_id
    , target_name
FROM {{ ref('stg_thanhtra_petition') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0