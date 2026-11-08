/*
*--------------------------------------------------------------------*
* Program code: atm_closed_investor_account
* Program name: Atomic Closed Investor Account
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[MOI] Theo lld_VSDC_CLOSED_INVESTORS.yaml.
* 2026-11-02		duc.luxuan			[VIET LAI] Theo dm_atm_closed_investor_account-VSDC.CLOSED_INVESTORS.yaml, cung cach atm_open_investor_account:
*                                       append, partition close_dt. 16 cot dung ten/thu tu/kieu thiet ke.
*--------------------------------------------------------------------*
*/

WITH investor AS (
    SELECT
        trading_account_no
        , customer_name
        , investor_type
        , address
        , id_number
        , issue_date
        , issue_place
        , close_date
        , nationality
        , phone_number
        , email
        , notes
    FROM {{ ref('ods_vsdc_closed_investors') }}
    WHERE close_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

nation AS (
    SELECT 
        autoid
    FROM {{ ref('ods_vsdc_nationality') }}
)

SELECT
    {{ generate_surrogate_key('VSDC_CLOSED_INVESTORS', "investor.trading_account_no") }} AS closed_investor_account_id
    , CAST('VSDC_CLOSED_INVESTORS' AS string)              AS src_stm_code
    , CAST(investor.trading_account_no AS string)          AS investor_account_nbr
    , CAST(investor.customer_name AS string)               AS investor_nm
    , CAST(investor.investor_type AS int)                  AS investor_tp_code
    , CAST(investor.address AS string)                     AS adr
    , CAST(investor.id_number AS string)                   AS identification_nbr
    , CAST(investor.issue_date AS date)                    AS issue_dt
    , CAST(investor.issue_place AS string)                 AS issue_place
    , CAST(investor.close_date AS date)                    AS close_dt
    , {{ generate_surrogate_key('VSDC_NATIONALITY', "nation.autoid") }} AS nationality_id
    , CAST(nation.autoid AS int)                           AS nationality_code
    , CAST(investor.phone_number AS string)                AS phone_nbr
    , CAST(investor.email AS string)                       AS email
    , CAST(investor.notes AS string)                       AS close_note
FROM investor
LEFT JOIN nation 
    ON investor.nationality = CAST(nation.autoid AS string)
