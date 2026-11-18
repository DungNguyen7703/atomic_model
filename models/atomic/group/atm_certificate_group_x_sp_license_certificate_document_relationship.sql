/*
*--------------------------------------------------------------------*
* Program code: atm_certificate_group_x_sp_license_certificate_document_relationship
* Program name: Atomic Certificate Group X Securities Practitioner License Certificate Document Relationship
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Tao model theo LLD NHNCK_CERTIFICATE_RECORD_GROUP_MEMBERS.
*--------------------------------------------------------------------*
*/

WITH ce_re_gr_me AS (
    SELECT
        id
        , certificate_record_group_id
        , certificate_record_id
    FROM {{ ref('ods_nhnck_certificate_record_group_members') }}
)

SELECT
    CAST('NHNCK_CERTIFICATE_RECORD_GROUP_MEMBERS' AS string)                                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATE_RECORDS', "ce_re_gr_me.certificate_record_id") }}             AS sp_license_certificate_document_id
    , CAST(ce_re_gr_me.certificate_record_id AS string)                                                                 AS sp_license_certificate_document_code
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATE_RECORD_GROUPS', "ce_re_gr_me.certificate_record_group_id") }} AS sp_license_certificate_group_id
    , CAST(ce_re_gr_me.certificate_record_group_id AS string)                                                           AS sp_license_certificate_group_code
FROM ce_re_gr_me