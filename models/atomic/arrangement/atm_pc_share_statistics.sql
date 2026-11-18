/*
*--------------------------------------------------------------------*
* Program code: atm_pc_share_statistics
* Program name: Atomic Public Company Share Statistics
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH co_sh_st_all AS (
    SELECT
        id
        , company_profile_id
        , total_issued_share
        , total_outstanding_share
        , total_outstanding_value
        , total_treasury_share
        , lastest_treasury_purchase_qty
        , lastest_treasury_purchase_end_date
        , preferred_share_type
        , total_preferred_share
        , total_preferred_value
        , row_number() over (partition by company_profile_id order by id desc) as rn
    FROM {{ ref('ods_ids_company_share_statistics') }}
),

co_sh_st AS (
    SELECT
        id
        , company_profile_id
        , total_issued_share
        , total_outstanding_share
        , total_outstanding_value
        , total_treasury_share
        , lastest_treasury_purchase_qty
        , lastest_treasury_purchase_end_date
        , preferred_share_type
        , total_preferred_share
        , total_preferred_value
    FROM co_sh_st_all
    where rn = 1
)


SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_SHARE_STATISTICS', "co_sh_st.id") }}           AS pc_share_statistics_id
    , CAST(co_sh_st.id AS string)                                                                AS pc_share_statistics_code
    , CAST('IDS_COMPANY_SHARE_STATISTICS' AS string)                                             AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "co_sh_st.company_profile_id") }} AS pc_id
    , CAST(co_sh_st.company_profile_id AS string)                                                AS pc_code
    , CAST(co_sh_st.total_issued_share AS int)                                                   AS total_issued_share_quantity
    , CAST(co_sh_st.total_outstanding_share AS int)                                              AS total_outstanding_share_quantity
    , CAST(co_sh_st.total_outstanding_value AS decimal(23,2))                                    AS total_outstanding_share_val_amt
    , CAST(co_sh_st.total_treasury_share AS int)                                                 AS total_treasury_share_quantity
    , CAST(co_sh_st.lastest_treasury_purchase_qty AS int)                                        AS latest_treasury_purchase_quantity
    , CAST(co_sh_st.lastest_treasury_purchase_end_date AS date)                                  AS latest_treasury_purchase_end_dt
    , CAST(co_sh_st.preferred_share_type AS string)                                              AS preferred_share_tp_nm
    , CAST(co_sh_st.total_preferred_share AS int)                                                AS total_preferred_share_quantity
    , CAST(co_sh_st.total_preferred_value AS decimal(23,2))                                      AS total_preferred_share_val_amt
FROM co_sh_st