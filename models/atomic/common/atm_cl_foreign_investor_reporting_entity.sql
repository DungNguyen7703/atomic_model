/*
*--------------------------------------------------------------------*
* Program code: atm_cl_foreign_investor_reporting_entity
* Program name: Atomic Classification Foreign Investor Reporting Entity
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH cl_fo_in_re_en AS (
    SELECT
        object_id
        , object_type
        , object_type_name
        , object_code
        , object_name
        , object_short_name
    FROM {{ source('source_fims_bcd', 'raw_cl_foreign_investor_reporting_entity') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_CL_FOREIGN_INVESTOR_REPORTING_ENTITY', "concat_ws('-', cl_fo_in_re_en.object_id, cl_fo_in_re_en.object_type)") }} AS cl_foreign_investor_reporting_entity_id
    , CAST(concat_ws('-', cl_fo_in_re_en.object_id, cl_fo_in_re_en.object_type) AS string) AS cl_foreign_investor_reporting_entity_code
    , CAST('FIMS_CL_FOREIGN_INVESTOR_REPORTING_ENTITY' AS string) AS src_stm_code
    , CAST(cl_fo_in_re_en.object_id AS string)                    AS reporting_entity_code
    , CAST(cl_fo_in_re_en.object_type AS string)                  AS reporting_entity_tp_code
    , CAST(cl_fo_in_re_en.object_type_name AS string)             AS reporting_entity_tp_nm
    , CAST(cl_fo_in_re_en.object_code AS string)                  AS entity_reference_nbr
    , CAST(cl_fo_in_re_en.object_name AS string)                  AS reporting_entity_nm
    , CAST(cl_fo_in_re_en.object_short_name AS string)            AS reporting_entity_short_nm
FROM cl_fo_in_re_en