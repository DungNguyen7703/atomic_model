/*
*--------------------------------------------------------------------*
* Program code: atm_cl_fims_status
* Program name: Atomic Classification FIMS Status
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH stat AS (
    SELECT
        code
        , name
        , description
        , typeobject
        , ecatalog_id
    FROM {{ ref('ods_fims_status') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_STATUS', "stat.code") }} AS cl_fims_status_id
    , CAST(stat.code AS string)                                     AS cl_fims_status_code
    , CAST('FIMS_STATUS' AS string)                                 AS src_stm_code
    , CAST(stat.name AS string)                                     AS cl_fims_status_nm
    , CAST(stat.description AS string)                              AS description
    , CAST(stat.typeobject AS string)                               AS object_tp_code
    , CAST(stat.ecatalog_id AS string)                              AS ecatalog_id
FROM stat