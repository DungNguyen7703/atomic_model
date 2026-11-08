/*
*--------------------------------------------------------------------*
* Program code: stg_iam_module
* Program name: Staging IAM.MODULE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo UAT_IAM_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(code AS string)             AS code
    , CAST(name AS string)             AS name
    , CAST(description AS string)      AS description
    , CAST(status AS int)              AS status
    , CAST(version AS int)             AS version
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(export_file_name AS string) AS export_file_name
FROM {{ source('source_iam', 'raw_module') }}