/*
*--------------------------------------------------------------------*
* Program code: stg_fms_company_type
* Program name: Staging FMS.COMPANY_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Them cot code (LLD Atomic FMS SECURITIES.cl_fms_company_tp_code <- COMPANY_TYPE.CODE)
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                         AS id
    , CAST(date_created AS timestamp) AS date_created
    , CAST(created_by AS string)    AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)     AS modify_by
    , CAST(item_name AS string)     AS item_name
    , CAST(description AS string)   AS description
    , CAST(record_status AS int)    AS record_status
    , CAST(system_object AS string) AS system_object
    , CAST(joint_stock AS int)      AS joint_stock
    , CAST(deleted AS int)          AS deleted
    , CAST(data_migration AS int)   AS data_migration
    , CAST(code AS string)          AS code
FROM {{ source('source_fms', 'raw_company_type') }}