/*
*--------------------------------------------------------------------*
* Program code: atm_cl_fims_investor_type
* Program name: Atomic Classification FIMS Investor Type
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH in_ty AS (
    SELECT
        sname
        , name
        , description
        , ecatalog_id
    FROM {{ ref('ods_fims_investortype') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_INVESTORTYPE', "in_ty.sname") }} AS cl_fims_investor_tp_id
    , CAST(in_ty.sname AS string)                                           AS cl_fims_investor_tp_code
    , CAST('FIMS_INVESTORTYPE' AS string)                                   AS src_stm_code
    , CAST(in_ty.name AS string)                                            AS cl_fims_investor_tp_nm
    , CAST(in_ty.description AS string)                                     AS description
    , CAST(in_ty.ecatalog_id AS string)                                     AS ecatalog_id
FROM in_ty