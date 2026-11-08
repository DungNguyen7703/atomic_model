/*
*--------------------------------------------------------------------*
* Program code: stg_fms_pension_provider
* Program name: Staging FMS.PENSION_PROVIDER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                               AS id
    , CAST(agent_type AS string)          AS agent_type
    , CAST(company_type AS int)           AS company_type
    , CAST(item_name AS string)           AS item_name
    , CAST(eng_name AS string)            AS eng_name
    , CAST(short_name AS string)          AS short_name
    , CAST(business_license_no AS string) AS business_license_no
    , CAST(license_issue_date AS date)    AS license_issue_date
    , CAST(license_issued_by AS string)   AS license_issued_by
    , CAST(tax_code AS string)            AS tax_code
    , CAST(address AS string)             AS address
    , CAST(phone AS string)               AS phone
    , CAST(fax AS string)                 AS fax
    , CAST(record_status AS int)          AS record_status
    , CAST(termination_date AS date)      AS termination_date
    , CAST(deleted AS int)                AS deleted
    , CAST(date_created AS timestamp)     AS date_created
    , CAST(created_by AS string)          AS created_by
    , CAST(date_modified AS timestamp)    AS date_modified
    , CAST(modify_by AS string)           AS modify_by
FROM {{ source('source_fms', 'raw_pension_provider') }}