/*
*--------------------------------------------------------------------*
* Program code: atm_ra_organization_unit
* Program name: Atomic Regulatory Authority Organization Unit NHNCK.UNITS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH unit AS (
    SELECT
        unit_code
        , unit_name
        , level_
        , parent_id
        , description
    FROM {{ ref('ods_nhnck_units') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_UNITS', "unit.unit_code") }}   AS ra_ou_id
    , CAST(unit.unit_code AS string)                                       AS ra_ou_code
    , CAST('NHNCK_UNITS' AS string)                                        AS src_stm_code
    , CAST(null AS string)                                                 AS ou_tp_code
    , CAST(unit.unit_name AS string)                                       AS ra_ou_nm
    , CAST(unit.level_ AS string)                                          AS hierarchy_level_code
    , {{ generate_surrogate_key_bigint('NHNCK_UNITS', "unit.parent_id") }} AS parent_ra_ou_id
    , CAST(unit.parent_id AS string)                                       AS parent_ra_ou_code
    , CAST(unit.description AS string)                                     AS description
    , CAST(null AS int)                                                    AS sort_order
FROM unit