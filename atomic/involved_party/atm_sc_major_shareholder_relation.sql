/*
*--------------------------------------------------------------------*
* Program code: atm_sc_major_shareholder_relation
* Program name: Atomic Securities Company Major Shareholder Relation
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_ma_sh_re AS (
    SELECT
        id
        , sc_firm_info_id
        , shareholder_id
        , individual
        , full_name
        , nationality_id
        , relationship
        , relation_start_date
        , relation_end_date
        , large_shareholder_date
        , ownership_ratio
        , shares_count
        , contributed_capital
        , note
        , created_at
    FROM {{ ref('ods_scms_sc_firm_major_shareholder_relation') }}
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
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_MAJOR_SHAREHOLDER_RELATION', "sc_fi_ma_sh_re.id") }} AS sc_major_shareholder_relation_id
    , CAST(sc_fi_ma_sh_re.id AS string)                                                                 AS sc_major_shareholder_relation_code
    , CAST('SCMS_SC_FIRM_MAJOR_SHAREHOLDER_RELATION' AS string)                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                         AS sc_id
    , CAST(sc_fi_in.code AS string)                                                                     AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SHAREHOLDER', "sc_fi_ma_sh_re.shareholder_id") }}  AS sc_shareholder_id
    , CAST(sc_fi_ma_sh_re.shareholder_id AS string)                                                     AS sc_shareholder_code
    , CAST(sc_fi_ma_sh_re.individual AS int)                                                            AS individual_ind
    , CAST(sc_fi_ma_sh_re.full_name AS string)                                                          AS full_nm
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "ca_na.nationality_code") }}                     AS nationality_id
    , CAST(ca_na.nationality_code AS string)                                                            AS nationality_code
    , CAST(sc_fi_ma_sh_re.relationship AS string)                                                       AS rltnp
    , CAST(sc_fi_ma_sh_re.relation_start_date AS date)                                                  AS relation_start_dt
    , CAST(sc_fi_ma_sh_re.relation_end_date AS date)                                                    AS relation_end_dt
    , CAST(sc_fi_ma_sh_re.large_shareholder_date AS date)                                               AS large_shareholder_dt
    , CAST(sc_fi_ma_sh_re.ownership_ratio AS decimal(5,2))                                              AS ownership_ratio
    , CAST(sc_fi_ma_sh_re.shares_count AS int)                                                          AS shares_count
    , CAST(sc_fi_ma_sh_re.contributed_capital AS decimal(23,2))                                         AS contributed_capital
    , CAST(sc_fi_ma_sh_re.note AS string)                                                               AS note
    , CAST(sc_fi_ma_sh_re.created_at AS timestamp)                                                      AS src_rcrd_isrt_tms
FROM sc_fi_ma_sh_re
    LEFT JOIN sc_fi_in ON sc_fi_ma_sh_re.SC_FIRM_INFO_ID = sc_fi_in.SC_FIRM_INFO_ID
    LEFT JOIN ca_na ON sc_fi_ma_sh_re.NATIONALITY_ID = ca_na.ID