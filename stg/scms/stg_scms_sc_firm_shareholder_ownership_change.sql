/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_shareholder_ownership_change
* Program name: Staging SCMS.SC_FIRM_SHAREHOLDER_OWNERSHIP_CHANGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang decimal(19,0) (4 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot); WHERE loc theo cot created_at trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: effective_date.
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (created_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(created_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))             AS id
    , CAST(sc_firm_info_id AS decimal(19,0)) AS sc_firm_info_id
    , CAST(shareholder_id AS decimal(19,0)) AS shareholder_id
    , CAST(capital_before AS decimal(22,4)) AS capital_before
    , CAST(ratio_before AS decimal(12,4))   AS ratio_before
    , CAST(capital_after AS decimal(22,4))  AS capital_after
    , CAST(ratio_after AS decimal(12,4))    AS ratio_after
    , CAST(transaction_type AS string)      AS transaction_type
    , CAST(document_number AS string)       AS document_number
    , CAST(effective_date AS date)      AS effective_date
    , CAST(attachment_path AS string)       AS attachment_path
    , CAST(data_source AS string)           AS data_source
    , CAST(note AS string)                  AS note
    , CAST(created_by AS decimal(19,0))     AS created_by
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(deleted AS int)                  AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_shareholder_ownership_change') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1