/*
*--------------------------------------------------------------------*
* Program code: stg_fms_brch_bup
* Program name: Staging FMS.BRCH_BUP
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
    , CAST(str_status AS string)         AS str_status
    , CAST(item_name AS string)          AS item_name
    , CAST(str_br_type AS string)        AS str_br_type
    , CAST(address AS string)            AS address
    , CAST(telephone AS string)          AS telephone
    , CAST(fax AS string)                AS fax
    , CAST(host_office AS int)           AS host_office
    , CAST(description AS string)        AS description
    , CAST(content AS string)            AS content
    , CAST(dorf AS int)                  AS dorf
    , CAST(file_name AS string)          AS file_name
    , CAST(file_data AS string)          AS file_data
    , CAST(stop_date AS date)            AS stop_date
    , CAST(active_date AS date)          AS active_date
    , CAST(decision AS string)           AS decision
    , CAST(decision_date AS date)        AS decision_date
    , CAST(br_idowner AS string)         AS br_idowner
    , CAST(deleted AS int)               AS deleted
    , CAST(tl_name AS string)            AS tl_name
    , CAST(voucher_no AS string)         AS voucher_no
    , CAST(voucher_date AS date)         AS voucher_date
    , CAST(des_change AS string)         AS des_change
    , CAST(str_securities AS string)     AS str_securities
    , CAST(str_tlprofiles AS string)     AS str_tlprofiles
    , CAST(str_business AS string)       AS str_business
    , CAST(sec_capital AS decimal(18,2)) AS sec_capital
    , CAST(sec_id_date AS date)          AS sec_id_date
    , CAST(sec_real_active_date AS date) AS sec_real_active_date
    , CAST(str_sec_address AS string)    AS str_sec_address
    , CAST(str_sec_fax AS string)        AS str_sec_fax
    , CAST(str_sec_id_add AS string)     AS str_sec_id_add
    , CAST(str_sec_id_no AS string)      AS str_sec_id_no
    , CAST(str_sec_name AS string)       AS str_sec_name
    , CAST(str_sec_reg_no AS string)     AS str_sec_reg_no
    , CAST(str_sec_telephone AS string)  AS str_sec_telephone
FROM {{ source('source_fms', 'raw_brch_bup') }}