/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_archives
* Program name: Staging NHNCK.APPLICATION_ARCHIVES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (4 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)               AS id
    , CAST(application_id AS bigint) AS application_id
    , CAST(location AS string)       AS location
    , CAST(phone_number AS string)   AS phone_number
    , CAST(contact AS string)        AS contact
    , CAST(note AS string)           AS note
    , CAST(created_at AS timestamp)  AS created_at
    , CAST(created_by AS bigint)     AS created_by
    , CAST(updated_at AS timestamp)  AS updated_at
    , CAST(updated_by AS bigint)     AS updated_by
FROM {{ source('source_nhnck', 'raw_application_archives') }}