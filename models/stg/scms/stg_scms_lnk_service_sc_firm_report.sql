/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_service_sc_firm_report
* Program name: Staging SCMS.LNK_SERVICE_SC_FIRM_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (5 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: WHERE loc theo cot created_at trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (created_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(created_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sc_firm_service_id AS bigint) AS sc_firm_service_id
    , CAST(form_report_id AS bigint)  AS form_report_id
    , CAST(sc_firm_info_id AS bigint) AS sc_firm_info_id
    , CAST(service_id AS bigint)      AS service_id
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(created_by AS bigint)      AS created_by
FROM {{ source('source_scms', 'raw_lnk_service_sc_firm_report') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1