/*
*--------------------------------------------------------------------*
* Program code: stg_fms_mb_fund
* Program name: Staging FMS.MB_FUND
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
    , CAST(date_created AS date)          AS date_created
    , CAST(created_by AS string)          AS created_by
    , CAST(date_modified AS date)         AS date_modified
    , CAST(modify_by AS string)           AS modify_by
    , HEX(fund_id)                        AS fund_id
    , HEX(nat_id)                         AS nat_id
    , HEX(st_id)                          AS st_id
    , CAST(item_name AS string)           AS item_name
    , CAST(dorf AS int)                   AS dorf
    , CAST(record_status AS int)          AS record_status
    , CAST(mb_id AS string)               AS mb_id
    , CAST(fn_code AS string)             AS fn_code
    , CAST(id_no AS string)               AS id_no
    , CAST(id_date AS date)               AS id_date
    , CAST(province AS string)            AS province
    , CAST(country AS string)             AS country
    , CAST(address AS string)             AS address
    , CAST(capital AS decimal(18,2))      AS capital
    , CAST(hold_qtty AS decimal(18,2))    AS hold_qtty
    , CAST(hold_percent AS decimal(18,2)) AS hold_percent
    , CAST(hold_date AS date)             AS hold_date
    , CAST(frepresent_date AS date)       AS frepresent_date
    , CAST(mb_type AS int)                AS mb_type
    , CAST(represent_job AS string)       AS represent_job
    , CAST(represent_name AS string)      AS represent_name
    , CAST(srepresent_date AS date)       AS srepresent_date
    , CAST(deleted AS int)                AS deleted
    , CAST(data_migration AS int)         AS data_migration
FROM {{ source('source_fms', 'raw_mb_fund') }}