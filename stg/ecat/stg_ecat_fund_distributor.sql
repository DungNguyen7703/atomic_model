/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_fund_distributor
* Program name: Staging ECAT.FUND_DISTRIBUTOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(name_vn AS string)                 AS name_vn
    , CAST(name_en AS string)                 AS name_en
    , CAST(short_name AS string)              AS short_name
    , CAST(head_office_address AS string)     AS head_office_address
    , CAST(phone_number AS string)            AS phone_number
    , CAST(fax AS string)                     AS fax
    , CAST(decision AS string)                AS decision
    , CAST(decision_date AS timestamp)        AS decision_date
    , CAST(decision_place AS string)          AS decision_place
    , CAST(active_date AS timestamp)          AS active_date
    , CAST(stop_date AS timestamp)            AS stop_date
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
FROM {{ source('source_ecat', 'raw_fund_distributor') }}