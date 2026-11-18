/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_major_shareholder
* Program name: ODS VSDC.MAJOR_SHAREHOLDER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(ticker_symbol AS string)              AS ticker_symbol
    , CAST(isin_code AS string)                AS isin_code
    , CAST(shareholder_name AS string)         AS shareholder_name
    , CAST(id_number AS string)                AS id_number
    , CAST(issue_date AS date)                 AS issue_date
    , CAST(contact_address AS string)          AS contact_address
    , CAST(voting_shares AS decimal(18,0))     AS voting_shares
    , CAST(begin_period_date AS date)          AS begin_period_date
    , CAST(begin_period_shares AS decimal(18,0)) AS begin_period_shares
    , CAST(begin_period_ratio AS decimal(10,2)) AS begin_period_ratio
    , CAST(end_period_date AS date)            AS end_period_date
    , CAST(end_period_shares AS decimal(18,0)) AS end_period_shares
    , CAST(end_period_ratio AS decimal(10,2))  AS end_period_ratio
    , CAST(notes AS string)                    AS notes
    , CAST(ds_snpst_dt AS date)                AS ds_snpst_dt
FROM {{ source('source_vsdc', 'raw_major_shareholder') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
