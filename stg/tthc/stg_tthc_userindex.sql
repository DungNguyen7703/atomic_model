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
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                         AS id
    , CAST(documentid AS int)                 AS documentid
    , CAST(normalizedusername AS string)      AS normalizedusername
    , CAST(normalizedemail AS string)         AS normalizedemail
    , CAST(isenabled AS decimal(38,0))        AS isenabled
    , CAST(islockoutenabled AS decimal(38,0)) AS islockoutenabled
    , CAST(lockoutendutc AS string)           AS lockoutendutc
    , CAST(accessfailedcount AS int)          AS accessfailedcount
    , CAST(userid AS string)                  AS userid
    , CAST(normalizeddisplayname AS string)   AS normalizeddisplayname
    , CAST(normalizedphone AS string)         AS normalizedphone
    , CAST(usertype AS string)                AS usertype
    , CAST(position AS string)                AS position
FROM {{ source('source_tthc', 'raw_userindex') }}