/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_indicator_field_meta
* Program name: Staging SCMS.FORM_INDICATOR_FIELD_META
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (1 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: WHERE loc theo cot created_at trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (created_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(created_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))             AS id
    , CAST(entity_code AS string)           AS entity_code
    , CAST(field_code AS string)            AS field_code
    , CAST(db_column_name AS string)        AS db_column_name
    , CAST(display_name AS string)          AS display_name
    , CAST(data_type AS string)             AS data_type
    , CAST(relation_type AS string)         AS relation_type
    , CAST(junction_table_name AS string)   AS junction_table_name
    , CAST(main_fk_column AS string)        AS main_fk_column
    , CAST(catalog_table_name AS string)    AS catalog_table_name
    , CAST(catalog_fk_column AS string)     AS catalog_fk_column
    , CAST(catalog_filter_column AS string) AS catalog_filter_column
    , CAST(sort_order AS bigint)            AS sort_order
    , CAST(record_status AS int)            AS record_status
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(value_source AS string)          AS value_source
    , CAST(string_format AS string)         AS string_format
FROM {{ source('source_scms', 'raw_form_indicator_field_meta') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1