/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_record_group_members
* Program name: Staging NHNCK.CERTIFICATE_RECORD_GROUP_MEMBERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (7 cot); kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                            AS id
    , CAST(certificate_record_group_id AS bigint) AS certificate_record_group_id
    , CAST(certificate_record_id AS bigint)       AS certificate_record_id
    , CAST(added_date AS timestamp)               AS added_date
    , CAST(added_by AS bigint)                    AS added_by
    , CAST(status AS bigint)                      AS status
    , CAST(is_reissue AS bigint)                  AS is_reissue
    , CAST(revocation_reason AS string)           AS revocation_reason
    , CAST(order_index AS bigint)                 AS order_index
FROM {{ source('source_nhnck', 'raw_certificate_record_group_members') }}