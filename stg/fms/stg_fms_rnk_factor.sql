/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rnk_factor
* Program name: Staging FMS.RNK_FACTOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu decimal(38,0) sang int (3 cot); kieu decimal(38,0) sang bigint (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(rk_id)                               AS rk_id
    , HEX(fctr_id)                           AS fctr_id
    , CAST(date_created AS date)             AS date_created
    , CAST(created_by AS string)             AS created_by
    , CAST(date_modified AS date)            AS date_modified
    , CAST(modify_by AS string)              AS modify_by
    , CAST(item_name AS string)              AS item_name
    , CAST(code AS string)                   AS code
    , CAST(weight AS int)                    AS weight
    , CAST(item_value AS decimal(38,2))      AS item_value
    , CAST(score_value AS int)               AS score_value
    , CAST(minus_score AS int)               AS minus_score
    , CAST(record_status AS int)             AS record_status
    , CAST(note AS string)                   AS note
    , CAST(ranking_value AS bigint)          AS ranking_value
    , CAST(nav_of_child_e4 AS bigint)        AS nav_of_child_e4
    , CAST(caculator AS string)              AS caculator
FROM {{ source('source_fms', 'raw_rnk_factor') }}