/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_accounting_practitioners
* Program name: Staging ECAT.ACCOUNTING_PRACTITIONERS
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
    CAST(id AS string)                      AS id
    , CAST(stable_id AS string)               AS stable_id
    , CAST(id_sync AS decimal(22,0))          AS id_sync
    , CAST(code AS string)                    AS code
    , CAST(accountant_name AS string)         AS accountant_name
    , CAST(gender AS string)                  AS gender
    , CAST(birth_year AS string)              AS birth_year
    , CAST(place_of_origin AS string)         AS place_of_origin
    , CAST(position AS string)                AS position
    , CAST(card_number AS string)             AS card_number
    , CAST(card_issue_date AS timestamp)      AS card_issue_date
    , CAST(company_id AS decimal(22,0))       AS company_id
    , CAST(company_code AS string)            AS company_code
    , CAST(is_part_time AS string)            AS is_part_time
    , CAST(effective AS string)               AS effective
    , CAST(effective_date AS timestamp)       AS effective_date
    , CAST(expiry_date AS timestamp)          AS expiry_date
    , CAST(occurrence_date AS timestamp)      AS occurrence_date
    , CAST(issuance_document AS string)       AS issuance_document
    , CAST(issuance_date AS timestamp)        AS issuance_date
    , CAST(note AS string)                    AS note
    , CAST(created_date AS timestamp)         AS created_date
    , CAST(modified_date AS timestamp)        AS modified_date
    , CAST(active AS int)                     AS active
    , CAST(active_reason AS string)           AS active_reason
    , CAST(deleted AS int)                    AS deleted
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(version AS int)                    AS version
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(old_id AS string)                  AS old_id
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
FROM {{ source('source_ecat', 'raw_accounting_practitioners') }}