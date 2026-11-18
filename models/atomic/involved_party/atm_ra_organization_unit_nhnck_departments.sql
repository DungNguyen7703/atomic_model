/*
*--------------------------------------------------------------------*
* Program code: atm_ra_organization_unit
* Program name: Atomic Regulatory Authority Organization Unit NHNCK.DEPARTMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH depa AS (
    SELECT
        department_code
        , department_name
        , unit_id
        , description
        , sort_order
    FROM {{ ref('ods_nhnck_departments') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_DEPARTMENTS', "depa.department_code") }} AS ra_ou_id
    , CAST(depa.department_code AS string)                                           AS ra_ou_code
    , CAST('NHNCK_DEPARTMENTS' AS string)                                            AS src_stm_code
    , CAST(null AS string)                                                           AS ou_tp_code
    , CAST(depa.department_name AS string)                                           AS ra_ou_nm
    , CAST(null AS string)                                                           AS hierarchy_level_code
    , {{ generate_surrogate_key_bigint('NHNCK_UNITS', "depa.unit_id") }}             AS parent_ra_ou_id
    , CAST(depa.unit_id AS string)                                                   AS parent_ra_ou_code
    , CAST(depa.description AS string)                                               AS description
    , CAST(depa.sort_order AS int)                                                   AS sort_order
FROM depa