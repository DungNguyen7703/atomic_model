/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_certificate_type_x_cl_specialization_relationship
* Program name: Atomic Securities Practitioner License Certificate Type X Classification Specialization Relationship
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Tao model theo LLD NHNCK_CERTIFICATE_SPECIALIZATIONS.
*--------------------------------------------------------------------*
*/

WITH ce_sp AS (
    SELECT
        id
        , certificate_id
        , specialization_id
        , document_type
        , is_required
    FROM {{ ref('ods_nhnck_certificate_specializations') }}
),

cert AS (
    SELECT
        id
        , certificate_code
    FROM {{ ref('ods_nhnck_certificates') }}
),

spec AS (
    SELECT
        id
        , specialization_code
    FROM {{ ref('ods_nhnck_specializations') }}
)

SELECT
    CAST('NHNCK_CERTIFICATE_SPECIALIZATIONS' AS string)                                AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATES', "cert.certificate_code") }} AS sp_license_certificate_tp_id
    , CAST(cert.certificate_code AS string)                                               AS sp_license_certificate_tp_code
    , CAST(spec.specialization_code AS string)                                           AS specialization_code
    , CAST(ce_sp.document_type AS string)                                                AS document_tp_code
    , CAST(ce_sp.is_required AS int)                                                     AS required_ind
FROM ce_sp
    LEFT JOIN cert ON ce_sp.CERTIFICATE_ID = cert.ID
    LEFT JOIN spec ON ce_sp.SPECIALIZATION_ID = spec.ID