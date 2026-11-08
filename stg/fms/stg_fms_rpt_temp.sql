/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rpt_temp
* Program name: Staging FMS.RPT_TEMP
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                   AS id
    , CAST(date_created AS date)              AS date_created
    , CAST(created_by AS string)              AS created_by
    , CAST(date_modified AS date)             AS date_modified
    , CAST(modify_by AS string)               AS modify_by
    , CAST(item_name AS string)               AS item_name
    , CAST(legal_basis AS string)             AS legal_basis
    , CAST(report_type AS decimal(18,2))      AS report_type
    , CAST(require_disclosure AS int)         AS require_disclosure
    , CAST(require_import AS int)             AS require_import
    , CAST(description AS string)             AS description
    , CAST(NULL AS string)                    AS file_data           -- NCLOB: du lieu file dinh kem, khong dung cho BI, de NULL tranh nang
    , CAST(record_status AS int)              AS record_status
    , CAST(self_member_setting AS int)        AS self_member_setting
    , CAST(deleted AS int)                    AS deleted
    , CAST(financial_report AS decimal(18,2)) AS financial_report
    , CAST(version AS decimal(18,2))          AS version
    , HEX(ftype_id)                           AS ftype_id
    , CAST(report_group AS bigint)            AS report_group
    , CAST(system_objects AS bigint)          AS system_objects
    , CAST(code AS string)                    AS code
    , CAST(audit_report AS int)               AS audit_report
    , CAST(check_price_setting AS int)        AS check_price_setting
    , CAST(date_used AS date)                 AS date_used
    , CAST(eform_enabled AS int)              AS eform_enabled
    , CAST(NULL AS string)                    AS eform_schema_json   -- NCLOB JSON schema/UI eform, khong dung cho BI, de NULL
FROM {{ source('source_fms', 'raw_rpt_temp') }}