/*
*--------------------------------------------------------------------*
* Program code: atm_sc_ownership_relation
* Program name: Atomic Securities Company Ownership Relation
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_OWNERSHIP_RELATION.yaml (14 cot, Relative/scd2); sc_id/sc_code lay tu SC_FIRM_INFO.CODE (join sc_firm_info_id = sc_fi_in.id); country_id crosswalk CAT_NATIONALITY.NATIONALITY_CODE -> hash ECAT_COUNTRY
* 2026-11-13		claude		[MOI] Noi kieu theo nguon: enterprise_tp_id int->bigint (nguon NUMBER(10,0)), ownership_ratio decimal(5,2)->decimal(10,2) (nguon NUMBER(10,2))
*--------------------------------------------------------------------*
*/

WITH sc_fi_ow_re AS (
    SELECT
        id
        , sc_firm_info_id
        , relation_type
        , company_name
        , enterprise_type_id
        , country_id
        , ownership_ratio
        , ownership_date
        , end_date
        , note
    FROM {{ ref('ods_scms_sc_firm_ownership_relation') }}
),

sc_fi_in AS (
    SELECT
        id
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
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_OWNERSHIP_RELATION', "sc_fi_ow_re.id") }} AS sc_ownership_relation_id
    , CAST(sc_fi_ow_re.id AS string)                                                         AS sc_ownership_relation_code
    , CAST('SCMS_SC_FIRM_OWNERSHIP_RELATION' AS string)                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}              AS sc_id
    , CAST(sc_fi_in.code AS string)                                                          AS sc_code
    , CAST(sc_fi_ow_re.relation_type AS string)                                              AS ownership_relation_tp_code
    , CAST(sc_fi_ow_re.company_name AS string)                                               AS company_nm
    , CAST(sc_fi_ow_re.enterprise_type_id AS bigint)                                         AS enterprise_tp_id
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "ca_na.nationality_code") }}          AS country_id
    , CAST(ca_na.nationality_code AS string)                                                 AS country_code
    , CAST(sc_fi_ow_re.ownership_ratio AS decimal(5,2))                                      AS ownership_ratio
    , CAST(sc_fi_ow_re.ownership_date AS date)                                               AS ownership_dt
    , CAST(sc_fi_ow_re.end_date AS date)                                                     AS end_dt
    , CAST(sc_fi_ow_re.note AS string)                                                       AS note
FROM sc_fi_ow_re
    LEFT JOIN sc_fi_in ON sc_fi_ow_re.sc_firm_info_id = sc_fi_in.id
    LEFT JOIN ca_na ON sc_fi_ow_re.country_id = ca_na.id