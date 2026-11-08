/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_notification_notificationindex
* Program name: Staging TTHC.NOTIFICATION_NOTIFICATIONINDEX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                AS id
    , CAST(documentid AS int)        AS documentid
    , CAST(notificationid AS string) AS notificationid
    , CAST(userid AS string)         AS userid
    , CAST(isread AS decimal(38,0))  AS isread
    , CAST(readatutc AS string)      AS readatutc
    , CAST(createdatutc AS string)   AS createdatutc
    , CAST(content AS string)        AS content
FROM {{ source('source_tthc', 'raw_notification_notificationindex') }}