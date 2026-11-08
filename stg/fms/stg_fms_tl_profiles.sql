/*
*--------------------------------------------------------------------*
* Program code: stg_fms_tl_profiles
* Program name: Staging FMS.TL_PROFILES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                 AS id
    , CAST(date_created AS date)            AS date_created
    , CAST(created_by AS string)            AS created_by
    , CAST(date_modified AS date)           AS date_modified
    , CAST(modify_by AS string)             AS modify_by
    , HEX(sec_id)                           AS sec_id
    , HEX(branch_id)                        AS branch_id
    , HEX(nat_id)                           AS nat_id
    , CAST(item_name AS string)             AS item_name
    , CAST(sex AS string)                   AS sex
    , CAST(id_no AS string)                 AS id_no
    , CAST(id_date AS date)                 AS id_date
    , CAST(qtty AS decimal(18,2))           AS qtty
    , CAST(record_status AS decimal(18,2))  AS record_status
    , CAST(id_add AS string)                AS id_add
    , CAST(description AS string)           AS description
    , CAST(cust_type AS string)             AS cust_type
    , CAST(jobfr_date AS date)              AS jobfr_date
    , CAST(jobclose_date AS date)           AS jobclose_date
    , CAST(cert_no AS string)               AS cert_no
    , CAST(cert_date AS date)               AS cert_date
    , CAST(address AS string)               AS address
    , CAST(telephone AS string)             AS telephone
    , CAST(fax AS string)                   AS fax
    , CAST(email AS string)                 AS email
    , CAST(deleted AS int)                  AS deleted
    , CAST(short_name AS string)            AS short_name
    , CAST(isr AS int)                      AS isr
    , CAST(isp AS int)                      AS isp
    , CAST(current_add AS string)           AS current_add
    , CAST(education AS string)             AS education
    , CAST(qualyfication AS string)         AS qualyfication
    , CAST(job_type AS int)                 AS job_type
    , CAST(politics AS int)                 AS politics
    , CAST(birth AS date)                   AS birth
    , CAST(place_of_birth AS string)        AS place_of_birth
    , CAST(cert_type AS string)             AS cert_type
    , CAST(isd AS string)                   AS isd
    , CAST(isi AS int)                      AS isi
    , CAST(host_office AS int)              AS host_office
    , CAST(file_name AS string)             AS file_name
    , CAST(file_data AS string)             AS file_data
    , CAST(record_type AS string)           AS record_type
    , CAST(mov_date AS date)                AS mov_date
    , CAST(add_work AS string)              AS add_work
    , CAST(employed AS string)              AS employed
    , CAST(posit_job AS string)             AS posit_job
    , CAST(time_work AS string)             AS time_work
    , CAST(profession AS string)            AS profession
    , CAST(cdy_acc AS string)               AS cdy_acc
    , CAST(pl_email AS string)              AS pl_email
    , CAST(swork_dte AS date)               AS swork_dte
    , CAST(fwork_dte AS date)               AS fwork_dte
    , CAST(fn_type AS string)               AS fn_type
    , CAST(department AS string)            AS department
    , CAST(cell_phone AS string)            AS cell_phone
    , CAST(certified AS int)                AS certified
    , HEX(insder_id)                        AS insder_id
    , HEX(busi_id)                          AS busi_id
    , CAST(confirm_status AS decimal(18,2)) AS confirm_status
    , CAST(data_migration AS int)           AS data_migration
    , HEX(event_type_id)                    AS event_type_id
    , CAST(edit_reason AS string)           AS edit_reason
    , CAST(event_payload AS string)         AS event_payload
FROM {{ source('source_fms', 'raw_tl_profiles') }}