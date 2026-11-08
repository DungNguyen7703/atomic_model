/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_group_members
* Program name: Staging NHNCK.APPLICATION_GROUP_MEMBERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (5 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(application_group_id AS bigint) AS application_group_id
    , CAST(application_id AS bigint)       AS application_id
    , CAST(status AS bigint)               AS status
    , CAST(notes AS string)                AS notes
    , CAST(order_index AS bigint)          AS order_index
FROM {{ source('source_nhnck', 'raw_application_group_members') }}