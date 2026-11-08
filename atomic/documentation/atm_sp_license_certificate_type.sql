/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_certificate_type
* Program name: Atomic Securities Practitioner License Certificate Type
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH cert AS (
    SELECT
        certificate_code
        , certificate_name
        , description
        , processing_days
        , sort_order
        , is_displayed
        , is_original_data
    FROM {{ ref('ods_nhnck_certificates') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATES', "cert.certificate_code") }} AS sp_license_certificate_tp_id
    , CAST(cert.certificate_code AS string)                                            AS sp_license_certificate_tp_code
    , CAST('NHNCK_CERTIFICATES' AS string)                                             AS src_stm_code
    , CAST(certificate_name AS string)                                                 AS certificate_tp_nm
    , CAST(cert.description AS string)                                                 AS description
    , CAST(cert.processing_days AS int)                                                AS processing_days
    , CAST(cert.sort_order AS int)                                                     AS sort_order
    , CAST(cert.is_displayed AS string)                                                AS displayed_indicator
    , CAST(cert.is_original_data AS string)                                            AS original_data_indicator
FROM cert