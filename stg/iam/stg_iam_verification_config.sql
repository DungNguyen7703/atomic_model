/*
*--------------------------------------------------------------------*
* Program code: stg_iam_verification_config
* Program name: Staging IAM.VERIFICATION_CONFIG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo UAT_IAM_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(config_key AS string)      AS config_key
    , CAST(config_value AS string)    AS config_value
    , CAST(config_unit AS string)     AS config_unit
    , CAST(description AS string)     AS description
    , CAST(display_order AS int)      AS display_order
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
    , CAST(version AS int)            AS version
FROM {{ source('source_iam', 'raw_verification_config') }}