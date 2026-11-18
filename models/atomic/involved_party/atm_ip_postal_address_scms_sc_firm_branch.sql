/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address SCMS.SC_FIRM_BRANCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_br AS (
    SELECT
        id
        , address
        , province_id
        , district_id
        , ward_id
        , record_status
    FROM {{ ref('ods_scms_sc_firm_branch') }}
    where record_status = 1
),

ca_pr AS (
    SELECT
        id
        , province_code
    FROM {{ ref('ods_scms_cat_province') }}
),

ca_di AS (
    SELECT
        id
        , district_code
    FROM {{ ref('ods_scms_cat_district') }}
),

ca_wa AS (
    SELECT
        id
        , ward_code
    FROM {{ ref('ods_scms_cat_ward') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_BRANCH', "sc_fi_br.id") }}         AS ip_id
    , CAST(sc_fi_br.id AS string)                                                     AS ip_code
    , CAST('SCMS_SC_FIRM_BRANCH' AS string)                                           AS src_stm_code
    , CAST('BRANCH' AS string)                                                        AS adr_tp_code
    , CAST(sc_fi_br.address AS string)                                                AS adr_val
    , CAST(NULL AS string)                                                            AS country_id
    , CAST(NULL AS string)                                                            AS country_code
    , {{ generate_surrogate_key_bigint('ECAT_PROVINCE_NEW', "ca_pr.province_code") }} AS province_id
    , CAST(ca_pr.province_code AS string)                                             AS province_code
    , {{ generate_surrogate_key_bigint('ECAT_DISTRICT_OLD', "ca_di.district_code") }} AS district_id
    , CAST(ca_di.district_code AS string)                                             AS district_code
    , {{ generate_surrogate_key_bigint('ECAT_WARD_NEW', "ca_wa.ward_code") }}         AS ward_id
    , CAST(ca_wa.ward_code AS string)                                                 AS ward_code
FROM sc_fi_br
    LEFT JOIN ca_pr ON sc_fi_br.PROVINCE_ID = ca_pr.ID
    LEFT JOIN ca_di ON sc_fi_br.DISTRICT_ID = ca_di.ID
    LEFT JOIN ca_wa ON sc_fi_br.WARD_ID = ca_wa.ID