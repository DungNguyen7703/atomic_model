/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_autoroutepartindex
* Program name: Staging TTHC.AUTOROUTEPARTINDEX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo staging_tthc.sql, brd_TTHC.yaml va khao sat du lieu nguon prod: kieu int sang bigint (1 cot); kieu decimal(38,0) sang int (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(documentid AS bigint)             AS documentid
    , CAST(contentitemid AS string)          AS contentitemid
    , CAST(containedcontentitemid AS string) AS containedcontentitemid
    , CAST(jsonpath AS string)               AS jsonpath
    , CAST(path AS string)                   AS path
    , CAST(published AS int)                 AS published
    , CAST(latest AS int)                    AS latest
FROM {{ source('source_tthc', 'raw_autoroutepartindex') }}