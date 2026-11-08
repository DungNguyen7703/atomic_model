/*
*--------------------------------------------------------------------*
* Program code: stg_fims_ward_new
* Program name: Staging FIMS.WARD_NEW
* Created by: tuan.nguyenvanb
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		tuan.nguyenvanb		[MOI] Bo sung STG theo FIMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))    AS id
    , CAST(code AS string)         AS code
    , CAST(namevn AS string)       AS namevn
    , CAST(nameen AS string)       AS nameen
    , CAST(provincecode AS string) AS provincecode
    , CAST(category AS string)     AS category
    , CAST(status AS int)          AS status
    , CAST(deleted AS int)         AS deleted
    , CAST(ecatalog_id AS string)  AS ecatalog_id
    , CAST(datecreated AS date)    AS datecreated
    , CAST(createdby AS string)    AS createdby
FROM {{ source('source_fims', 'raw_ward_new') }}