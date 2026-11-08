/*
*--------------------------------------------------------------------*
* Program code: stg_fms_represent
* Program name: Staging FMS.REPRESENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                          AS id
    , CAST(date_created AS date)     AS date_created
    , CAST(created_by AS string)     AS created_by
    , CAST(date_modified AS date)    AS date_modified
    , CAST(modify_by AS string)      AS modify_by
    , HEX(job_id)                    AS job_id
    , HEX(nat_id)                    AS nat_id
    , HEX(fund_id)                   AS fund_id
    , CAST(item_name AS string)      AS item_name
    , CAST(id_no AS string)          AS id_no
    , CAST(id_date AS date)          AS id_date
    , CAST(province AS string)       AS province
    , CAST(position AS string)       AS position
    , CAST(record_status AS int)     AS record_status
    , CAST(address AS string)        AS address
    , CAST(email AS string)          AS email
    , CAST(tel AS string)            AS tel
    , CAST(fax AS string)            AS fax
    , CAST(deleted AS int)           AS deleted
    , CAST(education AS string)      AS education
    , CAST(prof_qualifi AS string)   AS prof_qualifi
    , CAST(other_exp AS string)      AS other_exp
    , CAST(other_position AS string) AS other_position
    , CAST(description AS string)    AS description
    , CAST(member_type AS bigint)    AS member_type
    , CAST(data_migration AS int)    AS data_migration
    , HEX(origin_id)                 AS origin_id
FROM {{ source('source_fms', 'raw_represent') }}