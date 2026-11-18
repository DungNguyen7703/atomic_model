/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_sc_firm_foreign_branch_service
* Program name: Staging SCMS.LNK_SC_FIRM_FOREIGN_BRANCH_SERVICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (3 cot).
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (created_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(created_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(sc_firm_foreign_branch_id AS bigint) AS sc_firm_foreign_branch_id
    , CAST(service_id AS bigint)             AS service_id
    , CAST(created_at AS timestamp)          AS created_at
FROM {{ source('source_scms', 'raw_lnk_sc_firm_foreign_branch_service') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1