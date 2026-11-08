/*
*--------------------------------------------------------------------*
* Program code: stg_fms_cdt_warn
* Program name: Staging FMS.CDT_WARN
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                      AS id
    , CAST(date_created AS date)                 AS date_created
    , CAST(created_by AS string)                 AS created_by
    , CAST(date_modified AS date)                AS date_modified
    , CAST(modify_by AS string)                  AS modify_by
    , HEX(pr_wid)                                AS pr_wid
    , CAST(compare_type AS int)                  AS compare_type
    , HEX(other_wid)                             AS other_wid
    , CAST(other_wid_condition AS decimal(18,2)) AS other_wid_condition
    , CAST(from_value AS decimal(38,0))          AS from_value
    , CAST(from_value_condition AS bigint)       AS from_value_condition
    , CAST(to_value AS decimal(38,0))            AS to_value
    , CAST(to_value_condition AS bigint)         AS to_value_condition
    , CAST(record_status AS int)                 AS record_status
    , CAST(item_name AS string)                  AS item_name
    , CAST(other_wperiod_type AS bigint)         AS other_wperiod_type
    , CAST(other_wperiod_value AS string)        AS other_wperiod_value
    , CAST(pr_wperiod_type AS bigint)            AS pr_wperiod_type
    , CAST(pr_wperiod_value AS string)           AS pr_wperiod_value
    , CAST(number_day_run AS decimal(38,0))      AS number_day_run
    , CAST(warning_type AS bigint)               AS warning_type
FROM {{ source('source_fms', 'raw_cdt_warn') }}