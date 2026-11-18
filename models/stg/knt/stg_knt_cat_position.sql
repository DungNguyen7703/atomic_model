/*
*--------------------------------------------------------------------*
* Program code: stg_knt_cat_position
* Program name: Staging KNT.CAT_POSITION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: kieu int sang bigint (1 cot); kieu int sang decimal(38,10) (4 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                    AS id
    , CAST(position_code AS string)    AS position_code
    , CAST(position_name AS string)    AS position_name
    , CAST(original_data AS decimal(38,10)) AS original_data
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(created_by AS string)       AS created_by
    , CAST(last_modified_at AS timestamp)   AS last_modified_at
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(data_type AS decimal(38,10))     AS data_type
    , CAST(deleted AS decimal(38,10))       AS deleted
    , CAST(sync_enabled AS decimal(38,10))  AS sync_enabled
    , CAST(sync_id AS string)          AS sync_id
    , CAST(sync_id_sc_firm AS string)  AS sync_id_sc_firm
FROM {{ source('source_knt', 'raw_cat_position') }}