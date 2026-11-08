/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_user_roles
* Program name: Staging NHNCK.USER_ROLES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)        AS id
    , CAST(user_id AS bigint) AS user_id
    , CAST(role_id AS bigint) AS role_id
FROM {{ source('source_nhnck', 'raw_user_roles') }}