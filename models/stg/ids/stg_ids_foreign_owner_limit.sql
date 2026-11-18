/*
*--------------------------------------------------------------------*
* Program code: stg_ids_foreign_owner_limit
* Program name: Staging IDS.FOREIGN_OWNER_LIMIT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                         AS id
    , CAST(company_profile_id AS int)       AS company_profile_id
    , CAST(max_owner_rate AS decimal(10,4)) AS max_owner_rate
    , CAST(from_date AS date)               AS from_date
    , CAST(to_date AS date)                 AS to_date
    , CAST(created_by AS string)            AS created_by
    , CAST(created_date AS date)            AS created_date
    , CAST(updated_by AS string)            AS updated_by
    , CAST(updated_date AS date)            AS updated_date
    , CAST(delete_flg AS int)               AS delete_flg
    , CAST(sync_flg AS int)                 AS sync_flg
FROM {{ source('source_ids', 'raw_foreign_owner_limit') }}