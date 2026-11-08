/*
*--------------------------------------------------------------------*
* Program code: stg_fms_securities
* Program name: Staging FMS.SECURITIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Them country_id, province_id, ward_id (LLD Atomic FMS SECURITIES_IP_Postal_Address)
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , CAST(date_created AS date)         AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS date)        AS date_modified
    , CAST(modify_by AS string)          AS modify_by
    , HEX(status_id)                     AS status_id
    , CAST(item_name AS string)          AS item_name
    , CAST(tname AS string)              AS tname
    , CAST(ename AS string)              AS ename
    , CAST(short_name AS string)         AS short_name
    , CAST(code AS string)               AS code
    , CAST(address AS string)            AS address
    , CAST(telephone AS string)          AS telephone
    , CAST(fax AS string)                AS fax
    , CAST(website AS string)            AS website
    , CAST(id_no AS string)              AS id_no
    , CAST(id_date AS date)              AS id_date
    , CAST(id_add AS string)             AS id_add
    , CAST(capital AS decimal(18,2))     AS capital
    , CAST(total_qtty AS decimal(18,2))  AS total_qtty
    , CAST(business_type AS string)      AS business_type
    , CAST(borf_flag AS int)             AS borf_flag
    , HEX(insider_id)                    AS insider_id
    , CAST(description AS string)        AS description
    , CAST(stock_code AS string)         AS stock_code
    , CAST(market AS int)                AS market
    , CAST(email AS string)              AS email
    , CAST(national AS string)           AS national
    , HEX(sec_id)                        AS sec_id
    , CAST(fr_date AS date)              AS fr_date
    , CAST(to_date AS date)              AS to_date
    , CAST(stop_date AS date)            AS stop_date
    , CAST(active_date AS date)          AS active_date
    , CAST(record_type AS string)        AS record_type
    , CAST(deleted AS int)               AS deleted
    , CAST(pepresent_ative AS bigint)    AS pepresent_ative
    , HEX(public_id)                     AS public_id
    , CAST(file_name AS string)          AS file_name
    , CAST(file_data AS string)          AS file_data
    , CAST(org_name AS string)           AS org_name
    , CAST(tr_code AS string)            AS tr_code
    , CAST(listed AS string)             AS listed
    , CAST(public_listed AS string)      AS public_listed
    , CAST(reg_date AS date)             AS reg_date
    , CAST(fin_date AS date)             AS fin_date
    , CAST(dec_date AS date)             AS dec_date
    , CAST(voucher_no AS string)         AS voucher_no
    , CAST(direc_name AS string)         AS direc_name
    , CAST(deput_name AS string)         AS deput_name
    , CAST(des_change AS string)         AS des_change
    , CAST(activ_other AS string)        AS activ_other
    , CAST(foreign_type AS string)       AS foreign_type
    , CAST(org_national AS string)       AS org_national
    , CAST(org_id_no AS string)          AS org_id_no
    , CAST(real_business_type AS string) AS real_business_type
    , HEX(par_id)                        AS par_id
    , CAST(real_active_date AS date)     AS real_active_date
    , CAST(reg_no AS string)             AS reg_no
    , HEX(ct_id)                         AS ct_id
    , CAST(data_migration AS int)        AS data_migration
    , CAST(id_db_old AS string)          AS id_db_old
    , HEX(event_type_id)                 AS event_type_id
    , HEX(bank_id)                       AS bank_id
    , CAST(province_id AS string)        AS province_id
    , CAST(ward_id AS string)            AS ward_id
    , CAST(country_id AS string)         AS country_id    -- VARCHAR2(256) id danh muc eCAT, khong HEX (theo pattern for_brch.province_id)
FROM {{ source('source_fms', 'raw_securities') }}