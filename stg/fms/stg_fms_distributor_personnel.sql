/*
*--------------------------------------------------------------------*
* Program code: stg_fms_distributor_personnel
* Program name: Staging FMS.DISTRIBUTOR_PERSONNEL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                             AS id
    , HEX(distributor_location_id)      AS distributor_location_id
    , CAST(full_name AS string)         AS full_name
    , CAST(cert_no AS string)           AS cert_no
    , CAST(position AS string)          AS position
    , CAST(phone AS string)             AS phone
    , CAST(deleted AS int)              AS deleted
    , CAST(date_created AS timestamp)   AS date_created
    , CAST(created_by AS string)        AS created_by
    , CAST(date_modified AS timestamp)  AS date_modified
    , CAST(modify_by AS string)         AS modify_by
    , HEX(distributor_agent_id)         AS distributor_agent_id
    , CAST(gender AS int)               AS gender
    , CAST(birth_date AS date)          AS birth_date
    , CAST(birth_place AS string)       AS birth_place
    , CAST(id_no AS string)             AS id_no
    , CAST(id_date AS date)             AS id_date
    , CAST(id_place AS string)          AS id_place
    , CAST(nat_id AS string)            AS nat_id
    , CAST(nat_name AS string)          AS nat_name
    , CAST(permanent_address AS string) AS permanent_address
    , CAST(current_address AS string)   AS current_address
    , CAST(education AS string)         AS education
    , CAST(fax AS string)               AS fax
    , CAST(email AS string)             AS email
    , CAST(telephone AS string)         AS telephone
    , CAST(cell_phone AS string)        AS cell_phone
    , CAST(position_id AS string)       AS position_id
    , CAST(department AS string)        AS department
    , CAST(start_work_date AS date)     AS start_work_date
    , CAST(end_work_date AS date)       AS end_work_date
FROM {{ source('source_fms', 'raw_distributor_personnel') }}