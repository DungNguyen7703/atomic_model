/*
*--------------------------------------------------------------------*
* Program code: stg_fms_audit_firm
* Program name: Staging FMS.AUDIT_FIRM
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                    AS id
    , CAST(name_vi AS string)                  AS name_vi
    , CAST(name_en AS string)                  AS name_en
    , CAST(short_name AS string)               AS short_name
    , CAST(email AS string)                    AS email
    , CAST(fax AS string)                      AS fax
    , CAST(website AS string)                  AS website
    , CAST(address AS string)                  AS address
    , CAST(phone AS string)                    AS phone
    , CAST(chartered_capital AS decimal(20,2)) AS chartered_capital
    , CAST(business_license_no AS string)      AS business_license_no
    , CAST(license_date AS date)               AS license_date
    , CAST(license_place AS string)            AS license_place
    , CAST(approval_decision_no AS string)     AS approval_decision_no
    , CAST(record_status AS int)               AS record_status
    , CAST(deleted AS int)                     AS deleted
    , CAST(date_created AS timestamp)          AS date_created
    , CAST(date_modified AS timestamp)         AS date_modified
    , CAST(created_by AS string)               AS created_by
    , CAST(modify_by AS string)                AS modify_by
FROM {{ source('source_fms', 'raw_audit_firm') }}