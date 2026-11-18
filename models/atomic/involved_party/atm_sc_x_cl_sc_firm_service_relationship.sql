/*
*--------------------------------------------------------------------*
* Program code: atm_sc_x_cl_sc_firm_service_relationship
* Program name: Atomic Securities Company X Classification Securities Company Firm Service Relationship
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ln_sc_fi_se AS (
    SELECT
        id
        , sc_firm_info_id
        , service_id
        , license_number
        , license_date
        , start_date
        , end_date
    FROM {{ ref('ods_scms_lnk_sc_firm_service') }}
    WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
),

sc_fi_in AS (
    SELECT
        id
        , code
        , sc_firm_info_id
    FROM {{ ref('ods_scms_sc_firm_info') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                   AS sc_id
    , CAST(sc_fi_in.code AS string)                                                             AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_LNK_SC_FIRM_SERVICE', "ln_sc_fi_se.service_id") }} AS cl_sc_firm_service_id
    , CAST(ln_sc_fi_se.service_id AS string)                                                    AS cl_sc_firm_service_code
    , CAST('SCMS_LNK_SC_FIRM_SERVICE' AS string)                                                AS src_stm_code
    , CAST(ln_sc_fi_se.license_number AS string)                                                AS license_nbr
    , CAST(ln_sc_fi_se.license_date AS date)                                                    AS license_dt
    , CAST(ln_sc_fi_se.start_date AS date)                                                      AS start_dt
    , CAST(ln_sc_fi_se.end_date AS date)                                                        AS end_dt
FROM ln_sc_fi_se
    LEFT JOIN sc_fi_in ON ln_sc_fi_se.sc_firm_info_id = sc_fi_in.sc_firm_info_id