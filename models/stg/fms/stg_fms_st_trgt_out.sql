/*
*--------------------------------------------------------------------*
* Program code: stg_fms_st_trgt_out
* Program name: Staging FMS.ST_TRGT_OUT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                         AS id
    , HEX(tg_out_id)                AS tg_out_id
    , HEX(ftype_id)                 AS ftype_id
    , CAST(formulas_info AS string) AS formulas_info
    , CAST(str_formula AS string)   AS str_formula
FROM {{ source('source_fms', 'raw_st_trgt_out') }}