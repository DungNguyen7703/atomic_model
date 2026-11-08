/*
*--------------------------------------------------------------------*
* Program code: stg_fms_config
* Program name: Staging FMS.CONFIG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(from_column AS string)    AS from_column
    , CAST(to_column AS string)    AS to_column
    , CAST(from_table AS string)   AS from_table
    , CAST(to_table AS string)     AS to_table
    , CAST(table_lvl AS int)       AS table_lvl
    , CAST(column_index AS string) AS column_index
    , CAST(condition AS string)    AS condition
FROM {{ source('source_fms', 'raw_config') }}