/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rnk_fact_history
* Program name: Staging FMS.RNK_FACT_HISTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (3 cot).
* 2026-11-08		tuan.nguyenvanb		Theo design: update sang append: yml snapshot/ds_snpst_dt -> append/date_created; WHERE loc date_created = etl_date (giong cac bang *_history Append khac).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                          AS id
    , CAST(date_created AS timestamp) AS date_created
    , CAST(created_by AS string)     AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)      AS modify_by
    , CAST(report_year AS bigint)    AS report_year
    , CAST(period AS int)            AS period
    , CAST(data_label AS string)     AS data_label
    , CAST(date_save AS timestamp)   AS date_save
    , CAST(data_label_fac AS string) AS data_label_fac
    , CAST(supervisor_edited AS int) AS supervisor_edited
    , CAST(cells_meta AS string)     AS cells_meta
FROM {{ source('source_fms', 'raw_rnk_fact_history') }}
WHERE date_format(date_created, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')