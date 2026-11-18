/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_domestic_rep_office
* Program name: Staging SCMS.SC_FIRM_DOMESTIC_REP_OFFICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (5 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: office_license_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                      AS id
    , CAST(rep_office_name AS string)         AS rep_office_name
    , CAST(office_address AS string)          AS office_address
    , CAST(office_business_license AS string) AS office_business_license
    , CAST(office_license_date AS date)  AS office_license_date
    , CAST(head_representative AS string)     AS head_representative
    , CAST(nationality_id AS bigint)          AS nationality_id
    , CAST(note AS string)                    AS note
    , CAST(created_by AS bigint)              AS created_by
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(last_modified_by AS bigint)        AS last_modified_by
    , CAST(last_modified_at AS timestamp)     AS last_modified_at
    , CAST(sc_firm_info_id AS bigint)         AS sc_firm_info_id
FROM {{ source('source_scms', 'raw_sc_firm_domestic_rep_office') }}