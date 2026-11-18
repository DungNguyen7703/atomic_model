/*
*--------------------------------------------------------------------*
* Program code: atm_application_group_x_sp_license_application_relationship
* Program name: Atomic Application Group X Securities Practitioner License Application Relationship
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Tao model theo LLD NHNCK_APPLICATION_GROUP_MEMBERS.
*--------------------------------------------------------------------*
*/

WITH ap_gr_me AS (
    SELECT
        id
        , application_group_id
        , application_id
        , notes
        , order_index
    FROM {{ ref('ods_nhnck_application_group_members') }}
),

appl AS (
    SELECT
        id
        , application_code
    FROM {{ ref('ods_nhnck_applications') }}
)

SELECT
    CAST('NHNCK_APPLICATION_GROUP_MEMBERS' AS string)                                                AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_APPLICATION_GROUPS', "ap_gr_me.application_group_id") }} AS sp_license_application_group_id
    , CAST(ap_gr_me.application_group_id AS string)                                                    AS sp_license_application_group_code
    , {{ generate_surrogate_key_bigint('NHNCK_APPLICATIONS', "appl.application_code") }}               AS sp_license_application_id
    , CAST(appl.application_code AS string)                                                          AS sp_license_application_code
    , CAST(ap_gr_me.notes AS string)                                                                   AS member_notes
    , CAST(ap_gr_me.order_index AS int)                                                                AS member_sort_order
FROM ap_gr_me
    LEFT JOIN appl ON ap_gr_me.APPLICATION_ID = appl.ID