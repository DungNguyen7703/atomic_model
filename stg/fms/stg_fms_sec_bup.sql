/*
*--------------------------------------------------------------------*
* Program code: stg_fms_sec_bup
* Program name: Staging FMS.SEC_BUP
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , CAST(date_created AS date)         AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS date)        AS date_modified
    , CAST(modify_by AS string)          AS modify_by
    , HEX(sec_hs_id)                     AS sec_hs_id
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
    , CAST(reg_no AS string)             AS reg_no
    , CAST(real_active_date AS date)     AS real_active_date
    , CAST(str_stakes AS string)         AS str_stakes
    , CAST(str_branchs AS string)        AS str_branchs
    , CAST(str_tlprofiles AS string)     AS str_tlprofiles
    , CAST(str_business AS string)       AS str_business
    , CAST(str_inves AS string)          AS str_inves
    , CAST(str_status AS string)         AS str_status
    , CAST(str_par AS string)            AS str_par
    , CAST(str_company_type AS string)   AS str_company_type
    , CAST(str_funds AS string)          AS str_funds
    , CAST(str_trsfer_inders AS string)  AS str_trsfer_inders
    , CAST(str_insiders AS string)       AS str_insiders
    , CAST(deput_job AS string)          AS deput_job
FROM {{ source('source_fms', 'raw_sec_bup') }}