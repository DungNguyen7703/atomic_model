/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_workflowtypeindex
* Program name: Staging TTHC.WORKFLOWTYPEINDEX
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
    CAST(id AS int)                  AS id
    , CAST(documentid AS bigint)     AS documentid
    , CAST(workflowtypeid AS string)   AS workflowtypeid
    , CAST(name AS string)             AS name
    , CAST(isenabled AS int)         AS isenabled
    , CAST(hasstart AS int)          AS hasstart
    , CAST(currentversion AS int)      AS currentversion
FROM {{ source('source_tthc', 'raw_workflowtypeindex') }}