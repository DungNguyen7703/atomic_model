/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_userbyrolenameindex
* Program name: Staging TTHC.USERBYROLENAMEINDEX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)          AS id
    , CAST(rolename AS string) AS rolename
    , CAST(count AS int)       AS count
FROM {{ source('source_tthc', 'raw_userbyrolenameindex') }}