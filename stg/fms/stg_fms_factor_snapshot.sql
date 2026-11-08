/*
*--------------------------------------------------------------------*
* Program code: stg_fms_factor_snapshot
* Program name: Staging FMS.FACTOR_SNAPSHOT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                AS id
    , CAST(snapshot_json AS string)   AS snapshot_json
    , CAST(note AS string)            AS note
    , CAST(snapshot_at AS timestamp)  AS snapshot_at
    , CAST(date_created AS timestamp) AS date_created
    , CAST(created_by AS string)      AS created_by
FROM {{ source('source_fms', 'raw_factor_snapshot') }}
WHERE date_format(date_created, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')