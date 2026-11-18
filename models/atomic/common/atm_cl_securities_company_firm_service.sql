/*
*--------------------------------------------------------------------*
* Program code: atm_cl_securities_company_firm_service
* Program name: Atomic Classification Securities Company Firm Service
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ca_se_le_ca AS (
    SELECT
        service_id
        , service_name
        , description
        , catalog_type
        , catalog_code
        , application_type
        , legal_capital
        , record_status
    FROM {{ ref('ods_scms_cat_service_legal_capital') }}
    where record_status = 1
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_CAT_SERVICE_LEGAL_CAPITAL', "ca_se_le_ca.service_id") }} AS cl_sc_firm_service_id
    , CAST(ca_se_le_ca.service_id AS string)                                                        AS cl_sc_firm_service_code
    , CAST('SCMS_CAT_SERVICE_LEGAL_CAPITAL' AS string)                                              AS src_stm_code
    , CAST(ca_se_le_ca.service_name AS string)                                                      AS cl_sc_firm_service_nm
    , CAST(ca_se_le_ca.description AS string)                                                       AS description
    , CAST(ca_se_le_ca.catalog_type AS string)                                                      AS catalog_tp
    , CAST(ca_se_le_ca.catalog_code AS string)                                                      AS catalog_code
    , CAST(ca_se_le_ca.application_type AS string)                                                  AS application_tp_code
    , CAST(ca_se_le_ca.legal_capital AS decimal(23,2))                                              AS legal_capital_amt
FROM ca_se_le_ca