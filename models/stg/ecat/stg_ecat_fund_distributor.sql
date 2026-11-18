/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_fund_distributor
* Program name: Staging ECAT.FUND_DISTRIBUTOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu timestamp sang date (2 cot); them cot agent_type, company_type, reg_cert_no, reg_cert_date, reg_cert_place, distribution_platform_info, status_id, id_sync, tax_code.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(short_name AS string)              AS short_name
    , CAST(phone_number AS string)            AS phone_number
    , CAST(fax AS string)                     AS fax
    , CAST(decision AS string)                AS decision
    , CAST(decision_date AS date)                AS decision_date
    , CAST(active_date AS timestamp)          AS active_date
    , CAST(stop_date AS date)                    AS stop_date
    , CAST(operation_status AS int)           AS operation_status
    , CAST(note AS string)                    AS note
    , CAST(active AS int)                     AS active
    , CAST(active_reason AS string)           AS active_reason
    , CAST(deleted AS int)                    AS deleted
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(version AS int)                    AS version
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(old_id AS string)                  AS old_id
    , CAST(stable_id AS string)               AS stable_id
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(name_vn AS string)                 AS name_vn
    , CAST(name_en AS string)                 AS name_en
    , CAST(head_office_address AS string)     AS head_office_address
    , CAST(decision_place AS string)          AS decision_place
    , CAST(agent_type AS string)                 AS agent_type
    , CAST(company_type AS string)               AS company_type
    , CAST(reg_cert_no AS string)                AS reg_cert_no
    , CAST(reg_cert_date AS date)                AS reg_cert_date
    , CAST(reg_cert_place AS string)             AS reg_cert_place
    , CAST(distribution_platform_info AS string) AS distribution_platform_info
    , CAST(status_id AS string)                  AS status_id
    , CAST(id_sync AS string)                    AS id_sync
    , CAST(tax_code AS string)                   AS tax_code
FROM {{ source('source_ecat', 'raw_fund_distributor') }}