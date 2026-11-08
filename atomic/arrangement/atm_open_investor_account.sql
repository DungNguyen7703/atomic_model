/*
*--------------------------------------------------------------------*
* Program code: atm_open_investor_account
* Program name: Atomic Open Investor Account
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[MOI] Theo lld_VSDC_OPEN_INVESTORS.yaml.
* 2026-11-02		duc.luxuan			[VIET LAI] Theo dm_atm_open_investor_account-VSDC.OPEN_INVESTORS.yaml: Fact Snapshot
*                                       (incremental_rebase snapshot, partition ds_snpst_dt; macro tu them ds_snpst_dt = etl_date).
*                                       Moi ngay lay tai khoan mo trong ngay: ODS open_date = etl_date (golive VSDC phat sinh hang ngay)
*                                       -> ds_snpst_dt = open_dt. 14 cot dung ten/thu tu/kieu thiet ke.
*                                       CAN tao lai bang (ddl/20261102_vsdc_open_investors_repartition.sql) + backdate.
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
        , open_date
        , nationality
        , phone_number
        , email
    FROM {{ ref('ods_vsdc_open_investors') }}
    WHERE open_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

nation AS (
    SELECT 
        autoid
    FROM {{ ref('ods_vsdc_nationality') }}
)

SELECT
    {{ generate_surrogate_key('VSDC_OPEN_INVESTORS', "investor.trading_account_no") }} AS open_investor_account_id
    , CAST('VSDC_OPEN_INVESTORS' AS string)                AS src_stm_code
    , CAST(investor.trading_account_no AS string)          AS investor_account_nbr
    , CAST(investor.customer_name AS string)               AS investor_nm
    , CAST(investor.investor_type AS int)                  AS investor_tp_code
    , CAST(investor.address AS string)                     AS adr
    , CAST(investor.id_number AS string)                   AS identification_nbr
    , CAST(investor.issue_date AS date)                    AS issue_dt
    , CAST(investor.issue_place AS string)                 AS issue_place
    , CAST(investor.open_date AS date)                     AS open_dt
    , {{ generate_surrogate_key('VSDC_NATIONALITY', "nation.autoid") }} AS nationality_id
    , CAST(nation.autoid AS int)                           AS nationality_code
    , CAST(investor.phone_number AS string)                AS phone_nbr
    , CAST(investor.email AS string)                       AS email
FROM investor
LEFT JOIN nation 
    ON investor.nationality = CAST(nation.autoid AS string)