/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rank
* Program name: Staging FMS.RANK
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
    , CAST(date_created AS date)         AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS date)        AS date_modified
    , CAST(modify_by AS string)          AS modify_by
    , HEX(sec_id)                        AS sec_id
    , HEX(rt_pd_id)                      AS rt_pd_id
    , CAST(total_score AS decimal(38,0)) AS total_score
    , CAST(rank_index AS decimal(38,0))  AS rank_index
    , CAST(rank_type AS bigint)          AS rank_type
FROM {{ source('source_fms', 'raw_rank') }}