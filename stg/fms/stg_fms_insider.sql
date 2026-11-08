/*
*--------------------------------------------------------------------*
* Program code: stg_fms_insider
* Program name: Staging FMS.INSIDER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                AS id
    , CAST(date_created AS date)           AS date_created
    , CAST(created_by AS string)           AS created_by
    , CAST(date_modified AS date)          AS date_modified
    , CAST(modify_by AS string)            AS modify_by
    , HEX(sc_id)                           AS sc_id
    , HEX(nat_id)                          AS nat_id
    , HEX(s_id)                            AS s_id
    , HEX(tlpro_id)                        AS tlpro_id
    , CAST(item_name AS string)            AS item_name
    , CAST(id_no AS string)                AS id_no
    , CAST(id_date AS date)                AS id_date
    , CAST(id_add AS string)               AS id_add
    , CAST(insider_no AS string)           AS insider_no
    , CAST(tl_profile_linked AS int)       AS tl_profile_linked
    , CAST(tl_profile_in_sec AS int)       AS tl_profile_in_sec
    , CAST(insider_type AS decimal(18,2))  AS insider_type
    , CAST(capital AS decimal(18,2))       AS capital
    , CAST(qtty AS decimal(18,2))          AS qtty
    , CAST(reprecent AS decimal(18,2))     AS reprecent
    , CAST(per_date AS date)               AS per_date
    , CAST(record_status AS decimal(18,2)) AS record_status
    , CAST(description AS string)          AS description
    , CAST(address AS string)              AS address
    , CAST(telephone AS string)            AS telephone
    , CAST(fax AS string)                  AS fax
    , CAST(email AS string)                AS email
    , CAST(deleted AS int)                 AS deleted
    , CAST(data_migration AS int)          AS data_migration
    , CAST(birth AS date)                  AS birth
    , CAST(s_work_dte AS date)             AS s_work_dte
    , CAST(employ_status AS decimal(18,2)) AS employ_status
    , CAST(gp_qd_no AS string)             AS gp_qd_no
    , CAST(approval_date AS date)          AS approval_date
FROM {{ source('source_fms', 'raw_insider') }}