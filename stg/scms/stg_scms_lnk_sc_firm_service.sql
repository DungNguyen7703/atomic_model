/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_sc_firm_service
* Program name: Staging SCMS.LNK_SC_FIRM_SERVICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (3 cot); WHERE loc theo cot created_at trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: license_date, start_date, end_date.
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (created_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(created_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))              AS id
    , CAST(sc_firm_info_id AS decimal(19,0)) AS sc_firm_info_id
    , CAST(service_id AS decimal(19,0))      AS service_id
    , CAST(license_number AS string)         AS license_number
    , CAST(license_date AS date)        AS license_date
    , CAST(record_status AS bigint)          AS record_status
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(start_date AS date)          AS start_date
    , CAST(end_date AS date)            AS end_date
    , CAST(approval_file AS string)          AS approval_file
FROM {{ source('source_scms', 'raw_lnk_sc_firm_service') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1