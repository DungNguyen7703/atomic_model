/*
*--------------------------------------------------------------------*
* Program code: stg_knt_config_param
* Program name: Staging KNT.CONFIG_PARAM
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(param_code AS string)  AS param_code
    , CAST(param_name AS string)  AS param_name
    , CAST(value AS string)       AS value
    , CAST(description AS string) AS description
    , CAST(status AS int)         AS status
    , CAST(created_at AS date)    AS created_at
    , CAST(system_code AS int)    AS system_code
    , CAST(param_id AS int)       AS param_id
    , CAST(parent_id AS int)      AS parent_id
    , CAST(type AS int)           AS type
    , CAST(title AS string)       AS title
FROM {{ source('source_knt', 'raw_config_param') }}