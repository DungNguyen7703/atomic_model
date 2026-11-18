/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_permission_roles
* Program name: Staging NHNCK.PERMISSION_ROLES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)              AS id
    , CAST(permission_id AS bigint) AS permission_id
    , CAST(role_id AS bigint)       AS role_id
FROM {{ source('source_nhnck', 'raw_permission_roles') }}