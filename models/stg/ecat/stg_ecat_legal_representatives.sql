/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_legal_representatives
* Program name: Staging ECAT.LEGAL_REPRESENTATIVES
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(date_created AS timestamp)            AS date_created
    , CAST(created_by AS string)                 AS created_by
    , CAST(date_modified AS timestamp)           AS date_modified
    , CAST(modify_by AS string)                  AS modify_by
    , CAST(representative_id AS string)          AS representative_id
    , CAST(representative_name AS string)        AS representative_name
    , CAST(position AS string)                   AS position
    , CAST(fund_management_company_id AS string) AS fund_management_company_id
    , CAST(deleted AS int)                       AS deleted
    , CAST(id_sync AS string)                    AS id_sync
FROM {{ source('source_ecat', 'raw_legal_representatives') }}