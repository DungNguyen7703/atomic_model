/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_sc_firm_status
* Program name: Staging SCMS.CAT_SC_FIRM_STATUS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-25		tuan.nguyenvanb		Data change mode doi Append->Update (BRD-SRC
*									-SCMS-CAT_SC_FIRM_STATUS, Data Modeler xac
*									nhan 2026-09-16): bang danh muc (master),
*									khong phai event/log -> BO filter created_at,
*									doc toan bo nguon moi lan chay (Update toan
*									bo), giong pattern stg_scms_cat_event_type.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(sc_firm_status_code AS string)    AS sc_firm_status_code
    , CAST(sc_firm_status_name AS string)    AS sc_firm_status_name
    , CAST(note AS string)                   AS note
    , CAST(created_by AS bigint)             AS created_by
    , CAST(report_submission_enabled AS int) AS report_submission_enabled
    , CAST(disclosure_enabled AS int)        AS disclosure_enabled
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(record_status AS int)             AS record_status
    , CAST(active AS int)                    AS active
    , CAST(code AS string)                   AS code
    , CAST(item_name AS string)              AS item_name
    , CAST(applicable_entity AS string)      AS applicable_entity
    , CAST(description AS string)            AS description
FROM {{ source('source_scms', 'raw_cat_sc_firm_status') }}