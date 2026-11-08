/*
*--------------------------------------------------------------------*
* Program code: atm_pc_shareholding
* Program name: Atomic Public Company Shareholding
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH co_sh AS (
    SELECT
        id
        , company_profile_id
        , legal_entity_id
        , founder_hld_flg
        , founder_hld_active_date
        , founder_hld_inactive_date
        , major_hld_flg
        , major_hld_active_date
        , major_hld_inactive_date
        , strategic_hld_flg
        , strategic_hld_active_date
        , strategic_hld_inactive_date
        , insider_hld_flg
        , insider_hld_active_date
        , insider_hld_inactive_date
        , government_hld_flg
        , government_hld_active_date
        , government_hld_inactive_date
        , related_hld_flg
        , related_hld_active_date
        , related_hld_inactive_date
        , other_hld_flg
        , other_hld_active_date
        , other_hld_inactive_date
        , shareholder_type
        , ownership_qty
        , ownership_ratio
        , ownership_date
        , description
        , approval_flg
        , data_source_cd
        , data_updated_date
        , delete_flg
    FROM {{ ref('ods_ids_company_shareholding') }}
),

co_sh_2 AS (
    SELECT
        id AS company_shareholdingid
        , shareholder_type
        , COLLECT_LIST(
            NAMED_STRUCT('shareholder_tp_code', shareholder_type)
        ) AS shareholder_tp_code
    FROM {{ ref('ods_ids_company_shareholding') }}
    GROUP BY id, shareholder_type
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_SHAREHOLDING', "co_sh.id") }}               AS pc_shareholding_id
    , CAST(co_sh.id AS string)                                                                AS pc_shareholding_code
    , CAST('IDS_COMPANY_SHAREHOLDING' AS string)                                              AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "co_sh.company_profile_id") }} AS pc_id
    , CAST(co_sh.company_profile_id AS string)                                                AS pc_code
    , {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "co_sh.legal_entity_id") }}      AS legal_entity_id
    , CAST(co_sh.legal_entity_id AS string)                                                   AS legal_entity_code
    , CAST(co_sh.founder_hld_flg AS int)                                                      AS founder_shareholder_indicator
    , CAST(co_sh.founder_hld_active_date AS date)                                             AS founder_shareholder_active_dt
    , CAST(co_sh.founder_hld_inactive_date AS date)                                           AS founder_shareholder_inactive_dt
    , CAST(co_sh.major_hld_flg AS int)                                                        AS major_shareholder_indicator
    , CAST(co_sh.major_hld_active_date AS date)                                               AS major_shareholder_active_dt
    , CAST(co_sh.major_hld_inactive_date AS date)                                             AS major_shareholder_inactive_dt
    , CAST(co_sh.strategic_hld_flg AS int)                                                    AS strategic_shareholder_indicator
    , CAST(co_sh.strategic_hld_active_date AS date)                                           AS strategic_shareholder_active_dt
    , CAST(co_sh.strategic_hld_inactive_date AS date)                                         AS strategic_shareholder_inactive_dt
    , CAST(co_sh.insider_hld_flg AS int)                                                      AS insider_shareholder_indicator
    , CAST(co_sh.insider_hld_active_date AS date)                                             AS insider_shareholder_active_dt
    , CAST(co_sh.insider_hld_inactive_date AS date)                                           AS insider_shareholder_inactive_dt
    , CAST(co_sh.government_hld_flg AS int)                                                   AS government_shareholder_indicator
    , CAST(co_sh.government_hld_active_date AS date)                                          AS government_shareholder_active_dt
    , CAST(co_sh.government_hld_inactive_date AS date)                                        AS government_shareholder_inactive_dt
    , CAST(co_sh.related_hld_flg AS int)                                                      AS related_shareholder_indicator
    , CAST(co_sh.related_hld_active_date AS date)                                             AS related_shareholder_active_dt
    , CAST(co_sh.related_hld_inactive_date AS date)                                           AS related_shareholder_inactive_dt
    , CAST(co_sh.other_hld_flg AS int)                                                        AS other_shareholder_indicator
    , CAST(co_sh.other_hld_active_date AS date)                                               AS other_shareholder_active_dt
    , CAST(co_sh.other_hld_inactive_date AS date)                                             AS other_shareholder_inactive_dt
    , CAST(co_sh_2.shareholder_tp_code AS array<string>)                                      AS shareholder_tp_code
    , CAST(co_sh.ownership_qty AS int)                                                        AS ownership_quantity
    , CAST(co_sh.ownership_ratio AS decimal(5,2))                                             AS ownership_ratio_percentage
    , CAST(co_sh.ownership_date AS date)                                                      AS ownership_dt
    , CAST(co_sh.description AS string)                                                       AS description
    , CAST(co_sh.approval_flg AS int)                                                         AS approval_indicator
    , CAST(co_sh.data_source_cd AS string)                                                    AS data_src_code
    , CAST(co_sh.data_updated_date AS date)                                                   AS data_updated_dt
    , CAST(co_sh.delete_flg AS int)                                                           AS deleted_indicator
FROM co_sh
    LEFT JOIN co_sh_2 ON co_sh.ID = co_sh_2.Company_shareholdingID