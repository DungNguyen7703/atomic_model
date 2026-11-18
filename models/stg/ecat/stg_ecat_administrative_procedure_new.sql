/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_administrative_procedure_new
* Program name: Staging ECAT.ADMINISTRATIVE_PROCEDURE_NEW
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu decimal(38,10) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                       AS id
    , CAST(id_sync AS string)                  AS id_sync
    , CAST(code AS string)                     AS code
    , CAST(e_form_code AS string)              AS e_form_code
    , CAST(name AS string)                     AS name
    , CAST(field_name AS string)               AS field_name
    , CAST(field_id AS string)                 AS field_id
    , CAST(implementation_sequence AS string)  AS implementation_sequence
    , CAST(implementation_method AS string)    AS implementation_method
    , CAST(processing_time_amount AS bigint)   AS processing_time_amount
    , CAST(additional_days AS bigint)          AS additional_days
    , CAST(fee_amount AS decimal(19,2))        AS fee_amount
    , CAST(fee_payment_required AS int)        AS fee_payment_required
    , CAST(submit_result_to_leadership AS int) AS submit_result_to_leadership
    , CAST(multiple_types AS int)              AS multiple_types
    , CAST(applied_subject AS string)          AS applied_subject
    , CAST(procedure_level AS string)          AS procedure_level
    , CAST(competent_authority AS string)      AS competent_authority
    , CAST(coordinating_agency AS string)      AS coordinating_agency
    , CAST(procedure_group AS string)          AS procedure_group
    , CAST(legal_basis AS string)              AS legal_basis
    , CAST(implementation_result AS string)    AS implementation_result
    , CAST(note AS string)                     AS note
    , CAST(effective AS int)                   AS effective
    , CAST(active AS int)                      AS active
    , CAST(active_reason AS string)            AS active_reason
    , CAST(source_created_at AS timestamp)     AS source_created_at
    , CAST(source_updated_at AS timestamp)     AS source_updated_at
    , CAST(deleted AS int)                     AS deleted
    , CAST(deleted_reason AS string)           AS deleted_reason
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(created_by_id AS string)            AS created_by_id
    , CAST(created_by_name AS string)          AS created_by_name
    , CAST(updated_by_id AS string)            AS updated_by_id
    , CAST(updated_by_name AS string)          AS updated_by_name
    , CAST(version AS int)                     AS version
    , CAST(effective_start_date AS timestamp)  AS effective_start_date
    , CAST(effective_end_date AS timestamp)    AS effective_end_date
    , CAST(stable_id AS string)                AS stable_id
    , CAST(old_id AS string)                   AS old_id
    , CAST(processing_time_unit AS string)     AS processing_time_unit
FROM {{ source('source_ecat', 'raw_administrative_procedure_new') }}