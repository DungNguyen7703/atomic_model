/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_userindex
* Program name: Staging TTHC.USERINDEX
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
    CAST(id AS int)                         AS id
    , CAST(documentid AS bigint)            AS documentid
    , CAST(normalizedusername AS string)      AS normalizedusername
    , CAST(normalizedemail AS string)         AS normalizedemail
    , CAST(isenabled AS int)                AS isenabled
    , CAST(islockoutenabled AS int)         AS islockoutenabled
    , CAST(lockoutendutc AS string)           AS lockoutendutc
    , CAST(accessfailedcount AS int)          AS accessfailedcount
    , CAST(userid AS string)                  AS userid
    , CAST(normalizeddisplayname AS string)   AS normalizeddisplayname
    , CAST(normalizedphone AS string)         AS normalizedphone
    , CAST(usertype AS string)                AS usertype
    , CAST(position AS string)                AS position
FROM {{ source('source_tthc', 'raw_userindex') }}