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
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: WHERE loc theo BRD filter_logic; yml snapshot/ds_snpst_dt -> append/created_at theo BRD.
* 2026-11-08		tuan.nguyenvanb		Dong bo kieu theo dictionary Oracle KNT (query ket qua 2026-11-08, quy tac map cua DDL prod; CHUA khao sat du lieu): kieu int sang decimal(38,10) (4 cot); kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(param_code AS string)          AS param_code
    , CAST(param_name AS string)          AS param_name
    , CAST(value AS string)               AS value
    , CAST(description AS string)         AS description
    , CAST(status AS decimal(38,10))      AS status
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(system_code AS decimal(38,10)) AS system_code
    , CAST(param_id AS decimal(38,10))    AS param_id
    , CAST(parent_id AS decimal(38,10))   AS parent_id
    , CAST(type AS int)                   AS type
    , CAST(title AS string)               AS title
FROM {{ source('source_knt', 'raw_config_param') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1