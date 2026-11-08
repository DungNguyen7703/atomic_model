/*
*--------------------------------------------------------------------*
* Program code: stg_knt_tax_reg_address_type
* Program name: Staging KNT.TAX_REG_ADDRESS_TYPE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(tax_code AS string)      AS tax_code
    , CAST(type AS string)          AS type
    , CAST(address_type AS string)  AS address_type
    , CAST(address AS string)       AS address
    , CAST(ward AS string)          AS ward
    , CAST(district AS string)      AS district
    , CAST(province AS string)      AS province
    , CAST(ward_code AS string)     AS ward_code
    , CAST(district_code AS string) AS district_code
    , CAST(country AS string)       AS country
    , CAST(email AS string)         AS email
    , CAST(fax AS string)           AS fax
    , CAST(website AS string)       AS website
    , CAST(phone AS string)         AS phone
    , CAST(packet_code AS string)   AS packet_code
FROM {{ source('source_knt', 'raw_tax_reg_address_type') }}