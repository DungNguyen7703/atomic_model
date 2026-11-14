/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_public_company_version_map
* Program name: Staging ECAT.PUBLIC_COMPANY_VERSION_MAP
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(public_company_version_id AS string) AS public_company_version_id
    , CAST(entity_type AS string)               AS entity_type
    , CAST(entity_version_id AS string)         AS entity_version_id
    , CAST(created_at AS timestamp)             AS created_at
FROM {{ source('source_ecat', 'raw_public_company_version_map') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1