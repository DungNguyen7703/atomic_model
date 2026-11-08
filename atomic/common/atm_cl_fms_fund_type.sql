/*
*--------------------------------------------------------------------*
* Program code: atm_cl_fms_fund_type
* Program name: Atomic Classification FMS Fund Type
* Created by:
* Created date: 2026-10-09
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-09		claude				Khoi tao theo dm_atm_cl_fms_fund_type-FMS.FUND_TYPE.yaml
*										Promote tu Classification Value (scheme FMS_FUND_TYPE) len entity rieng; BK = ID nguon
*--------------------------------------------------------------------*
*/

WITH fund_ty AS (
    SELECT
        id
        , item_name
        , description
        , is_open_fund
    FROM {{ ref('ods_fms_fund_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_FUND_TYPE', "id") }}     AS cl_fms_fund_tp_id
    , CAST(id AS string)                                           AS cl_fms_fund_tp_code
    , CAST('FMS_FUND_TYPE' AS string)                              AS src_stm_code
    , CAST(item_name AS string)                                    AS cl_fms_fund_tp_nm
    , CAST(description AS string)                                  AS description
    , CAST(is_open_fund AS int)                                    AS open_fund_ind
FROM fund_ty
