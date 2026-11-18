/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_userbyclaimindex
* Program name: Staging TTHC.USERBYCLAIMINDEX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)            AS id
    , CAST(documentid AS int)    AS documentid
    , CAST(claimtype AS string)  AS claimtype
    , CAST(claimvalue AS string) AS claimvalue
FROM {{ source('source_tthc', 'raw_userbyclaimindex') }}