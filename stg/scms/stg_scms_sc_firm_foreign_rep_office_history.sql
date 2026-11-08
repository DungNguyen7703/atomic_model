/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_foreign_rep_office_history
* Program name: Staging SCMS.SC_FIRM_FOREIGN_REP_OFFICE_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: yml chuyen snapshot/ds_snpst_dt sang append/performed_at.
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot); WHERE loc theo cot performed_at trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: effective_date.
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (performed_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(performed_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                            AS id
    , CAST(sc_firm_foreign_rep_office_id AS decimal(19,0)) AS sc_firm_foreign_rep_office_id
    , CAST(performed_at AS timestamp)                      AS performed_at
    , CAST(event_type_id AS decimal(19,0))                 AS event_type_id
    , CAST(event_type_name AS string)                      AS event_type_name
    , CAST(before_info AS string)                          AS before_info
    , CAST(after_info AS string)                           AS after_info
    , CAST(document_number AS string)                      AS document_number
    , CAST(effective_date AS date)                    AS effective_date
    , CAST(document_file_path AS string)                   AS document_file_path
    , CAST(note AS string)                                 AS note
    , CAST(performed_by AS decimal(19,0))                  AS performed_by
    , CAST(performer_name AS string)                       AS performer_name
    , CAST(before_data_json AS string)                     AS before_data_json
    , CAST(after_data_json AS string)                      AS after_data_json
    , CAST(admin_procedure_profile_id AS string)           AS admin_procedure_profile_id
FROM {{ source('source_scms', 'raw_sc_firm_foreign_rep_office_history') }}
WHERE date_format(performed_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(performed_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1