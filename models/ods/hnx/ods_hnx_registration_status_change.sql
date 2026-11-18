/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_registration_status_change
* Program name: ODS HNX.REGISTRATION_STATUS_CHANGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(bond_code AS string)                                   AS bond_code
    , CAST(issuer_name AS string)                                AS issuer_name
    , CAST(par_value AS decimal(18,2))                           AS par_value
    , CAST(currently_registered_trading_volume AS bigint)        AS currently_registered_trading_volume
    , CAST(first_trading_date AS date)                           AS first_trading_date
    , CAST(last_trading_date AS date)                            AS last_trading_date
    , CAST(trading_registration_status AS string)                AS trading_registration_status
    , CAST(report_month AS string)                                AS report_month
    , CAST(ds_snpst_dt AS date)                                   AS ds_snpst_dt
FROM {{ source('source_hnx', 'raw_registration_status_change') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
