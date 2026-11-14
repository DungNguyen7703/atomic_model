/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rank
* Program name: Staging FMS.RANK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu decimal(38,0) sang int (2 cot).
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
    , CAST(total_score AS int)           AS total_score
    , CAST(rank_index AS int)            AS rank_index
    , CAST(rank_type AS bigint)          AS rank_type
FROM {{ source('source_fms', 'raw_rank') }}