/*
*--------------------------------------------------------------------*
* Program code: stg_tms_account_group
* Program name: Staging TMS.ACCOUNT_GROUP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                     AS id
    , CAST(group_code AS string)             AS group_code
    , CAST(group_name AS string)             AS group_name
    , CAST(securities_code_id AS string)     AS securities_code_id
    , CAST(stock_code AS string)             AS stock_code
    , CAST(case_file_id AS string)           AS case_file_id
    , CAST(case_code AS string)              AS case_code
    , CAST(relation_type_id AS string)       AS relation_type_id
    , CAST(characteristic AS string)         AS characteristic
    , CAST(group_type AS int)                AS group_type
    , CAST(contact_person_account AS string) AS contact_person_account
    , CAST(approval_status AS int)           AS approval_status
    , CAST(created_by_id AS string)          AS created_by_id
    , CAST(created_by_name AS string)        AS created_by_name
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(updated_by_id AS string)          AS updated_by_id
    , CAST(updated_by_name AS string)        AS updated_by_name
    , CAST(updated_at AS timestamp)          AS updated_at
    , CAST(deleted AS int)                   AS deleted
FROM {{ source('source_tms', 'raw_account_group') }}