/*
*--------------------------------------------------------------------*
* Program code: stg_ids_company_shareholding
* Program name: Staging IDS.COMPANY_SHAREHOLDING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                              AS id
    , CAST(company_profile_id AS int)            AS company_profile_id
    , CAST(legal_entity_id AS int)               AS legal_entity_id
    , CAST(founder_hld_flg AS int)               AS founder_hld_flg
    , CAST(founder_hld_active_date AS date)      AS founder_hld_active_date
    , CAST(founder_hld_inactive_date AS date)    AS founder_hld_inactive_date
    , CAST(major_hld_flg AS int)                 AS major_hld_flg
    , CAST(major_hld_active_date AS date)        AS major_hld_active_date
    , CAST(major_hld_inactive_date AS date)      AS major_hld_inactive_date
    , CAST(strategic_hld_flg AS int)             AS strategic_hld_flg
    , CAST(strategic_hld_active_date AS date)    AS strategic_hld_active_date
    , CAST(strategic_hld_inactive_date AS date)  AS strategic_hld_inactive_date
    , CAST(insider_hld_flg AS int)               AS insider_hld_flg
    , CAST(insider_hld_active_date AS date)      AS insider_hld_active_date
    , CAST(insider_hld_inactive_date AS date)    AS insider_hld_inactive_date
    , CAST(government_hld_flg AS int)            AS government_hld_flg
    , CAST(government_hld_active_date AS date)   AS government_hld_active_date
    , CAST(government_hld_inactive_date AS date) AS government_hld_inactive_date
    , CAST(related_hld_flg AS int)               AS related_hld_flg
    , CAST(related_hld_active_date AS date)      AS related_hld_active_date
    , CAST(related_hld_inactive_date AS date)    AS related_hld_inactive_date
    , CAST(other_hld_flg AS int)                 AS other_hld_flg
    , CAST(other_hld_active_date AS date)        AS other_hld_active_date
    , CAST(other_hld_inactive_date AS date)      AS other_hld_inactive_date
    , CAST(shareholder_type AS string)           AS shareholder_type
    , CAST(ownership_qty AS int)                 AS ownership_qty
    , CAST(ownership_ratio AS decimal(7,4))      AS ownership_ratio
    , CAST(ownership_date AS date)               AS ownership_date
    , CAST(description AS string)                AS description
    , CAST(approval_flg AS int)                  AS approval_flg
    , CAST(data_source_cd AS int)                AS data_source_cd
    , CAST(data_updated_date AS date)            AS data_updated_date
    , CAST(created_by AS string)                 AS created_by
    , CAST(created_date AS date)                 AS created_date
    , CAST(updated_by AS string)                 AS updated_by
    , CAST(updated_date AS date)                 AS updated_date
    , CAST(delete_flg AS int)                    AS delete_flg
FROM {{ source('source_ids', 'raw_company_shareholding') }}