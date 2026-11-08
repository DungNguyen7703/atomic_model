/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rnk_fact_history
* Program name: Staging FMS.RNK_FACT_HISTORY
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
    , CAST(report_year AS bigint)    AS report_year
    , CAST(period AS int)            AS period
    , CAST(data_label AS string)     AS data_label
    , CAST(date_save AS date)        AS date_save
    , CAST(data_label_fac AS string) AS data_label_fac
    , CAST(supervisor_edited AS int) AS supervisor_edited
    , CAST(cells_meta AS string)     AS cells_meta
FROM {{ source('source_fms', 'raw_rnk_fact_history') }}