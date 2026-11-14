/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_securities
* Program name: Staging ECAT.SECURITIES
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu decimal(38,10) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(sec_key AS string)                    AS sec_key
    , CAST(security_symbol_code AS string)       AS security_symbol_code
    , CAST(security_ticker_code AS string)       AS security_ticker_code
    , CAST(security_type AS string)              AS security_type
    , CAST(security_type_vi AS string)           AS security_type_vi
    , CAST(security_subtype AS string)           AS security_subtype
    , CAST(security_subtype_vi AS string)        AS security_subtype_vi
    , CAST(security_industry_code AS string)     AS security_industry_code
    , CAST(security_industry_name_vi AS string)  AS security_industry_name_vi
    , CAST(security_industry_name_eng AS string) AS security_industry_name_eng
    , CAST(first_trading_date AS timestamp)      AS first_trading_date
    , CAST(settlement_date AS timestamp)         AS settlement_date
    , CAST(listing_date AS timestamp)            AS listing_date
    , CAST(last_trading_date AS timestamp)       AS last_trading_date
    , CAST(security_type_id AS string)           AS security_type_id
    , CAST(security_type_version_id AS string)   AS security_type_version_id
    , CAST(effective AS int)                     AS effective
    , CAST(active_reason AS string)              AS active_reason
    , CAST(deleted AS int)                       AS deleted
    , CAST(deleted_reason AS string)             AS deleted_reason
    , CAST(version AS int)                       AS version
    , CAST(effective_start_date AS timestamp)    AS effective_start_date
    , CAST(effective_end_date AS timestamp)      AS effective_end_date
    , CAST(stable_id AS string)                  AS stable_id
    , CAST(old_id AS string)                     AS old_id
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(updated_at AS timestamp)              AS updated_at
    , CAST(created_by_id AS string)              AS created_by_id
    , CAST(created_by_name AS string)            AS created_by_name
    , CAST(updated_by_id AS string)              AS updated_by_id
    , CAST(updated_by_name AS string)            AS updated_by_name
    , CAST(security_name AS string)              AS security_name
    , CAST(issuer_place AS string)               AS issuer_place
FROM {{ source('source_ecat', 'raw_securities') }}