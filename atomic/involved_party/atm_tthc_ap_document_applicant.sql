/*
*--------------------------------------------------------------------*
* Program code: atm_tthc_ap_document_applicant
* Program name: Atomic TTHC Administrative Procedure Document Applicant
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ods AS (
    SELECT
        ap_document_applicant_id,
        display_name,
        phone_number,
        email
    FROM {{ ref('ods_tthc_ap_document_applicant') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('TTHC_AP_DOCUMENT_APPLICANT', "ods.ap_document_applicant_id") }}  AS ap_document_applicant_id
    , CAST(ods.ap_document_applicant_id AS string)                                                      AS ap_document_applicant_code
    , CAST('TTHC_AP_DOCUMENT_APPLICANT' AS string)                                                      AS src_stm_code
    , CAST(ods.display_name AS string)                                                                  AS display_nm
    , CAST(ods.phone_number AS string)                                                                  AS phone_nbr
    , CAST(ods.email AS string)                                                                         AS email
FROM ods
