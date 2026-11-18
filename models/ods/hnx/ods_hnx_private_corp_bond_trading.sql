/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_private_corp_bond_trading
* Program name: ODS HNX.PRIVATE_CORP_BOND_TRADING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(indicator AS string)             AS indicator
    , CAST(unit AS string)                AS unit
    , CAST(value AS decimal(18,4))        AS value
    , CAST(ds_snpst_dt AS date)           AS ds_snpst_dt
FROM {{ source('source_hnx', 'raw_private_corp_bond_trading') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
