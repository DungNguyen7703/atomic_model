/*
*--------------------------------------------------------------------*
* Program code: atm_ra_organization_unit_x_sp_license_certificate_type_relationship
* Program name: Atomic Regulatory Authority Organization Unit X Securities Practitioner License Certificate Type Relationship
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Tao model theo LLD NHNCK_CERTIFICATE_DEPARTMENTS.
*--------------------------------------------------------------------*
*/

WITH ce_de AS (
    SELECT
        id
        , certificate_id
        , department_id
    FROM {{ ref('ods_nhnck_certificate_departments') }}
),

depa AS (
    SELECT
        id
        , department_code
    FROM {{ ref('ods_nhnck_departments') }}
),

cert AS (
    SELECT
        id
        , certificate_code
    FROM {{ ref('ods_nhnck_certificates') }}
)

SELECT
    CAST('NHNCK_CERTIFICATE_DEPARTMENTS' AS string)                                    AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_DEPARTMENTS', "depa.department_code") }}   AS ra_ou_id
    , CAST(depa.department_code AS string)                                                AS ra_ou_code
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATES', "cert.certificate_code") }} AS sp_license_certificate_tp_id
    , CAST(cert.certificate_code AS string)                                               AS sp_license_certificate_tp_code
FROM ce_de
    LEFT JOIN depa ON ce_de.DEPARTMENT_ID = depa.ID
    LEFT JOIN cert ON ce_de.CERTIFICATE_ID = cert.ID