/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rnk_gr_ftor
* Program name: Staging FMS.RNK_GR_FTOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu decimal(38,0) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(rk_id)                          AS rk_id
    , HEX(gr_ft_id)                     AS gr_ft_id
    , CAST(item_value AS decimal(18,2)) AS item_value
    , CAST(code AS string)              AS code
    , CAST(item_name AS string)         AS item_name
    , CAST(weight AS int)               AS weight
FROM {{ source('source_fms', 'raw_rnk_gr_ftor') }}