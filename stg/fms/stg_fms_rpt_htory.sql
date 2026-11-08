/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rpt_htory
* Program name: Staging FMS.RPT_HTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                          AS id
    , HEX(rpt_id)                    AS rpt_id
    , CAST(action AS string)         AS action
    , CAST(version AS decimal(18,2)) AS version
    , CAST(downloaded AS int)        AS downloaded
    , CAST(date_created AS date)     AS date_created
    , CAST(created_by AS string)     AS created_by
    , CAST(code AS string)           AS code
FROM {{ source('source_fms', 'raw_rpt_htory') }}
WHERE date_format(date_created, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')