/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_administrative_procedure
* Program name: Staging ECAT.ADMINISTRATIVE_PROCEDURE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(code AS string)                         AS code
    , CAST(name AS string)                         AS name
    , CAST(description AS string)                  AS description
    , CAST(field_group AS string)                  AS field_group
    , CAST(implementation_sequence AS string)      AS implementation_sequence
    , CAST(procedure_group AS string)              AS procedure_group
    , CAST(procedure_level AS string)              AS procedure_level
    , CAST(implementation_method AS string)        AS implementation_method
    , CAST(applied_subject AS string)              AS applied_subject
    , CAST(processing_time_amount AS bigint)       AS processing_time_amount
    , CAST(processing_time_unit AS string)         AS processing_time_unit
    , CAST(fee_unit_currency_id AS string)         AS fee_unit_currency_id
    , CAST(fee_payment_method AS string)           AS fee_payment_method
    , CAST(coordinating_agency AS string)          AS coordinating_agency
    , CAST(legal_basis AS string)                  AS legal_basis
    , CAST(effective_status_date AS timestamp)     AS effective_status_date
    , CAST(expiration_status_date AS timestamp)    AS expiration_status_date
    , CAST(active AS int)                          AS active
    , CAST(active_reason AS string)                AS active_reason
    , CAST(deleted AS int)                         AS deleted
    , CAST(deleted_reason AS string)               AS deleted_reason
    , CAST(version AS int)                         AS version
    , CAST(effective_start_date AS timestamp)      AS effective_start_date
    , CAST(effective_end_date AS timestamp)        AS effective_end_date
    , CAST(old_id AS string)                       AS old_id
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(updated_at AS timestamp)                AS updated_at
    , CAST(created_by_id AS string)                AS created_by_id
    , CAST(created_by_name AS string)              AS created_by_name
    , CAST(updated_by_id AS string)                AS updated_by_id
    , CAST(updated_by_name AS string)              AS updated_by_name
    , CAST(implementation_result AS string)        AS implementation_result
    , CAST(stable_id AS string)                    AS stable_id
    , CAST(fee_unit_currency_version_id AS string) AS fee_unit_currency_version_id
    , CAST(fee_amount AS bigint)                   AS fee_amount
    , CAST(effective AS int)                       AS effective
    , CAST(competent_authority AS string)          AS competent_authority
FROM {{ source('source_ecat', 'raw_administrative_procedure') }}