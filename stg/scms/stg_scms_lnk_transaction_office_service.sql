/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_transaction_office_service
* Program name: Staging SCMS.LNK_TRANSACTION_OFFICE_SERVICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: WHERE loc theo cot created_at trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (created_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(created_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                              AS id
    , CAST(sc_firm_transaction_office_id AS bigint) AS sc_firm_transaction_office_id
    , CAST(service_id AS bigint)                    AS service_id
    , CAST(created_at AS timestamp)                 AS created_at
    , CAST(record_status AS bigint)                 AS record_status
FROM {{ source('source_scms', 'raw_lnk_transaction_office_service') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1