/*
*--------------------------------------------------------------------*
* Program code: atm_sc_shareholder
* Program name: Atomic Securities Company Shareholder
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_sh AS (
    SELECT
        id
        , sc_firm_info_id
        , sc_firm_personnel_id
        , shareholder_type
        , shareholder_entity_type
        , nationality_id
        , individual
        , shareholder_name
        , date_of_birth
        , place_of_birth
        , issue_date
        , issue_place
        , education_level
        , degree
        , occupation
        , workplace
        , job_title
        , trading_account
        , org_short_name
        , legal_representative_name
        , representative_position
        , shares_held
        , freely_tradable_shares
        , pledged_shares
        , restricted_shares
        , ownership_ratio
        , contributed_capital
        , large_shareholder_date
        , controlling_shareholder
        , founding_shareholder
        , owner
        , party_member
        , legal_entity_representative
        , company_employee
        , foreign_investment
        , note
        , created_at
    FROM {{ ref('ods_scms_sc_firm_shareholder') }}
),

sc_fi_in AS (
    SELECT
        sc_firm_info_id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
),

ca_na AS (
    SELECT
        id
        , nationality_code
    FROM {{ ref('ods_scms_cat_nationality') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SHAREHOLDER', "sc_fi_sh.id") }}                          AS sc_shareholder_id
    , CAST(sc_fi_sh.id AS string)                                                                           AS sc_shareholder_code
    , CAST('SCMS_SC_FIRM_SHAREHOLDER' AS string)                                                            AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                             AS sc_id
    , CAST(sc_fi_in.code AS string)                                                                         AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SENIOR_PERSONNEL', "sc_fi_sh.sc_firm_personnel_id") }} AS sc_senior_personnel_id
    , CAST(sc_fi_sh.sc_firm_personnel_id AS string)                                                         AS sc_senior_personnel_code
    , CAST(sc_fi_sh.shareholder_type AS string)                                                             AS shareholder_tp_code
    , CAST(sc_fi_sh.shareholder_entity_type AS string)                                                      AS shareholder_entity_tp_code
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "ca_na.nationality_code") }}                         AS nationality_id
    , CAST(ca_na.nationality_code AS string)                                                                AS nationality_code
    , CAST(sc_fi_sh.individual AS int)                                                                      AS individual_ind
    , CAST(sc_fi_sh.shareholder_name AS string)                                                             AS shareholder_nm
    , CAST(sc_fi_sh.date_of_birth AS date)                                                                  AS dt_of_birth
    , CAST(sc_fi_sh.place_of_birth AS string)                                                               AS place_of_birth
    , CAST(sc_fi_sh.issue_date AS date)                                                                     AS issue_dt
    , CAST(sc_fi_sh.issue_place AS string)                                                                  AS issue_place
    , CAST(sc_fi_sh.education_level AS string)                                                              AS education_level
    , CAST(sc_fi_sh.degree AS string)                                                                       AS degree
    , CAST(sc_fi_sh.occupation AS string)                                                                   AS occupation
    , CAST(sc_fi_sh.workplace AS string)                                                                    AS workplace
    , CAST(sc_fi_sh.job_title AS string)                                                                    AS job_title
    , CAST(sc_fi_sh.trading_account AS string)                                                              AS trading_account
    , CAST(sc_fi_sh.org_short_name AS string)                                                               AS org_short_nm
    , CAST(sc_fi_sh.legal_representative_name AS string)                                                    AS legal_representative_nm
    , CAST(sc_fi_sh.representative_position AS string)                                                      AS representative_position
    , CAST(sc_fi_sh.shares_held AS bigint)                                                                  AS shares_held
    , CAST(sc_fi_sh.freely_tradable_shares AS bigint)                                                       AS freely_tradable_shares
    , CAST(sc_fi_sh.pledged_shares AS bigint)                                                               AS pledged_shares
    , CAST(sc_fi_sh.restricted_shares AS bigint)                                                            AS restricted_shares
    , CAST(sc_fi_sh.ownership_ratio AS decimal(5,2))                                                        AS ownership_ratio
    , CAST(sc_fi_sh.contributed_capital AS decimal(23,2))                                                   AS contributed_capital
    , CAST(sc_fi_sh.large_shareholder_date AS date)                                                         AS large_shareholder_dt
    , CAST(sc_fi_sh.controlling_shareholder AS string)                                                      AS controlling_shareholder
    , CAST(sc_fi_sh.founding_shareholder AS int)                                                            AS founding_shareholder_ind
    , CAST(sc_fi_sh.owner AS int)                                                                           AS owner_ind
    , CAST(sc_fi_sh.party_member AS int)                                                                    AS party_member_ind
    , CAST(sc_fi_sh.legal_entity_representative AS int)                                                     AS legal_entity_representative_ind
    , CAST(sc_fi_sh.company_employee AS int)                                                                AS company_employee_ind
    , CAST(sc_fi_sh.foreign_investment AS int)                                                              AS foreign_investment_ind
    , CAST(sc_fi_sh.note AS string)                                                                         AS note
    , CAST(sc_fi_sh.created_at AS timestamp)                                                                AS src_rcrd_isrt_tms
FROM sc_fi_sh
    LEFT JOIN sc_fi_in ON sc_fi_sh.SC_FIRM_INFO_ID = sc_fi_in.SC_FIRM_INFO_ID
    LEFT JOIN ca_na ON sc_fi_sh.NATIONALITY_ID = ca_na.ID