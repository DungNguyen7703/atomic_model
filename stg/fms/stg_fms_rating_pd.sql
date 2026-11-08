/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rating_pd
* Program name: Staging FMS.RATING_PD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                            AS id
    , CAST(date_created AS date)       AS date_created
    , CAST(created_by AS string)       AS created_by
    , CAST(date_modified AS date)      AS date_modified
    , CAST(modify_by AS string)        AS modify_by
    , CAST(report_year AS bigint)      AS report_year
    , CAST(period AS int)              AS period
    , CAST(record_status AS int)       AS record_status
    , CAST(update_data_rating AS date) AS update_data_rating
    , CAST(rating_finalized AS int)    AS rating_finalized
FROM {{ source('source_fms', 'raw_rating_pd') }}