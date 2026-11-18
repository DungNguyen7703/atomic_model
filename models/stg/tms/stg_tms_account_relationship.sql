/*
*--------------------------------------------------------------------*
* Program code: stg_tms_account_relationship
* Program name: Staging TMS.ACCOUNT_RELATIONSHIP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                       AS id
    , CAST(account_id_1 AS string)             AS account_id_1
    , CAST(account_id_2 AS string)             AS account_id_2
    , CAST(account_code_1 AS string)           AS account_code_1
    , CAST(account_code_2 AS string)           AS account_code_2
    , CAST(account_group_id AS string)         AS account_group_id
    , CAST(relationship_id AS string)          AS relationship_id
    , CAST(relationship_value AS string)       AS relationship_value
    , CAST(strength AS int)                    AS strength
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(created_by_id AS string)            AS created_by_id
    , CAST(updated_by_id AS string)            AS updated_by_id
    , CAST(created_by_name AS string)          AS created_by_name
    , CAST(updated_by_name AS string)          AS updated_by_name
    , CAST(deleted AS int)                     AS deleted
    , CAST(transaction_review_id AS string)    AS transaction_review_id
    , CAST(case_file_id AS string)             AS case_file_id
    , CAST(relationship_code AS string)        AS relationship_code
    , CAST(relationship_type AS decimal(22,0)) AS relationship_type
    , CAST(version AS decimal(22,0))           AS version
    , CAST(workflow_id AS string)              AS workflow_id
    , CAST(source_account_code AS string)      AS source_account_code
FROM {{ source('source_tms', 'raw_account_relationship') }}