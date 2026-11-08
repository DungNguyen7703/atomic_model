/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_aliaspartindex
* Program name: Staging TTHC.ALIASPARTINDEX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                  AS id
    , CAST(documentid AS int)          AS documentid
    , CAST(alias AS string)            AS alias
    , CAST(contentitemid AS string)    AS contentitemid
    , CAST(latest AS decimal(38,0))    AS latest
    , CAST(published AS decimal(38,0)) AS published
FROM {{ source('source_tthc', 'raw_aliaspartindex') }}