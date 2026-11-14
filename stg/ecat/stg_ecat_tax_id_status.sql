/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_tax_id_status
* Program name: Staging ECAT.TAX_ID_STATUS
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu date sang timestamp (3 cot); kieu decimal(38,10) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(tax_id_code AS string)                    AS tax_id_code
    , CAST(tax_id_name AS string)                    AS tax_id_name
    , CAST(tax_id_declaration_document AS string)    AS tax_id_declaration_document
    , CAST(tax_id_declaration_document_date AS date) AS tax_id_declaration_document_date
    , CAST(created_date AS timestamp)                AS created_date
    , CAST(created_user AS string)                   AS created_user
    , CAST(last_updated_date AS date)                AS last_updated_date
    , CAST(last_updated_user AS string)              AS last_updated_user
    , CAST(sync_date AS date)                        AS sync_date
    , CAST(effective_from_date AS timestamp)         AS effective_from_date
    , CAST(effective_to_date AS timestamp)           AS effective_to_date
    , CAST(effective AS int)                         AS effective
    , CAST(effective_reason AS string)               AS effective_reason
    , CAST(deleted AS int)                           AS deleted
    , CAST(deleted_reason AS string)                 AS deleted_reason
    , CAST(version AS int)                           AS version
    , CAST(effective_start_date AS timestamp)        AS effective_start_date
    , CAST(effective_end_date AS timestamp)          AS effective_end_date
    , CAST(old_id AS string)                         AS old_id
    , CAST(stable_id AS string)                      AS stable_id
    , CAST(created_at AS timestamp)                  AS created_at
    , CAST(updated_at AS timestamp)                  AS updated_at
    , CAST(created_by_id AS string)                  AS created_by_id
    , CAST(created_by_name AS string)                AS created_by_name
    , CAST(updated_by_id AS string)                  AS updated_by_id
    , CAST(updated_by_name AS string)                AS updated_by_name
FROM {{ source('source_ecat', 'raw_tax_id_status') }}