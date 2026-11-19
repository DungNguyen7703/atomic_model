/*
*--------------------------------------------------------------------*
* Program code: ods_ecat_administrative_procedure
* Program name: ODS ECAT.ADMINISTRATIVE_PROCEDURE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-10		tra		Them dieu kien loc ban ghi con hieu luc (theo ods_filters.pdf): effective = 1 AND active = 1 AND deleted = 0 AND effective_end_date IS NULL
*--------------------------------------------------------------------*
*/

SELECT
    id
    , code
    , name
    , description
    , field_group
    , implementation_sequence
    , procedure_group
    , procedure_level
    , implementation_method
    , applied_subject
    , processing_time_amount
    , processing_time_unit
    , fee_unit_currency_id
    , fee_payment_method
    , coordinating_agency
    , legal_basis
    , effective_status_date
    , expiration_status_date
    , active
    , active_reason
    , deleted
    , deleted_reason
    , version
    , effective_start_date
    , effective_end_date
    , old_id
    , created_at
    , updated_at
    , created_by_id
    , created_by_name
    , updated_by_id
    , updated_by_name
    , implementation_result
    , stable_id
    , fee_unit_currency_version_id
    , fee_amount
    , effective
    , competent_authority
FROM {{ ref('stg_ecat_administrative_procedure') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND effective = 1
  AND active = 1
  AND deleted = 0
  AND effective_end_date IS NULL