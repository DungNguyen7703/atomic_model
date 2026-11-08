/*
*--------------------------------------------------------------------*
* Program code: stg_knt_company_info
* Program name: Staging KNT.COMPANY_INFO
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                           AS id
    , CAST(name AS string)                      AS name
    , CAST(company_type AS int)                 AS company_type
    , CAST(changed_at AS date)                  AS changed_at
    , CAST(tax_code AS string)                  AS tax_code
    , CAST(address AS string)                   AS address
    , CAST(phone AS string)                     AS phone
    , CAST(fax AS string)                       AS fax
    , CAST(website AS string)                   AS website
    , CAST(business_line AS string)             AS business_line
    , CAST(legal_representative_name AS string) AS legal_representative_name
    , CAST(charter_capital AS string)           AS charter_capital
    , CAST(public_company_reg_date AS date)     AS public_company_reg_date
    , CAST(decision_number AS string)           AS decision_number
    , CAST(ticker_symbol AS string)             AS ticker_symbol
    , CAST(listing_date AS date)                AS listing_date
    , CAST(listing_exchange AS string)          AS listing_exchange
    , CAST(first_listing_date AS date)          AS first_listing_date
    , CAST(shareholder_count AS int)            AS shareholder_count
    , CAST(delisting_date AS date)              AS delisting_date
    , CAST(public_company_end_date AS date)     AS public_company_end_date
    , CAST(msg_packet_id AS int)                AS msg_packet_id
    , CAST(guid AS string)                      AS guid
    , CAST(business_license AS string)          AS business_license
    , CAST(record_count AS int)                 AS record_count
FROM {{ source('source_knt', 'raw_company_info') }}