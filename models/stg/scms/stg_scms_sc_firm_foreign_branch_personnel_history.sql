/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_foreign_branch_personnel_history
* Program name: Staging SCMS.SC_FIRM_FOREIGN_BRANCH_PERSONNEL_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (3 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: WHERE loc theo cot performed_at trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (performed_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(performed_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(sc_firm_foreign_branch_id AS bigint) AS sc_firm_foreign_branch_id
    , CAST(performer_name AS string)         AS performer_name
    , CAST(personnel_id AS bigint)           AS personnel_id
    , CAST(content AS string)                AS content
    , CAST(action AS string)                 AS action
    , CAST(performed_at AS timestamp)        AS performed_at
FROM {{ source('source_scms', 'raw_sc_firm_foreign_branch_personnel_history') }}
WHERE date_format(performed_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(performed_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1