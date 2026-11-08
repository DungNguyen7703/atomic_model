/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rating_pd_snapshot
* Program name: Staging FMS.RATING_PD_SNAPSHOT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , HEX(rt_pd_id)                      AS rt_pd_id
    , HEX(sec_id)                        AS sec_id
    , CAST(total_score AS decimal(38,0)) AS total_score
    , CAST(rank_index AS decimal(38,0))  AS rank_index
    , CAST(rank_type AS bigint)          AS rank_type
    , CAST(note AS string)               AS note
    , CAST(snapshot_at AS timestamp)     AS snapshot_at
    , CAST(date_created AS timestamp)    AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS timestamp)   AS date_modified
    , CAST(modify_by AS string)          AS modify_by
    , CAST(factors_json AS string)       AS factors_json
FROM {{ source('source_fms', 'raw_rating_pd_snapshot') }}