/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_citizen_reception_subject
* Program name: Staging THANHTRA.CITIZEN_RECEPTION_SUBJECT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-08
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-08		tuan.nguyenvanb		[MOI] Bo sung STG theo THANHTRA_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                           AS id
    , CAST(citizen_reception_id AS string)         AS citizen_reception_id
    , CAST(full_name AS string)                    AS full_name
    , CAST(id_number AS string)                    AS id_number
    , CAST(address AS string)                      AS address
    , CAST(phone AS string)                        AS phone
    , CAST(organization_name AS string)            AS organization_name
    , CAST(business_registration_number AS string) AS business_registration_number
    , CAST(sort_order AS int)                      AS sort_order
    , CAST(created_at AS date)                     AS created_at
    , CAST(last_modified_at AS date)               AS last_modified_at
    , CAST(created_by AS string)                   AS created_by
    , CAST(last_modified_by AS string)             AS last_modified_by
    , CAST(version AS bigint)                      AS version
    , CAST(deleted AS int)                         AS deleted
FROM {{ source('source_thanhtra', 'raw_citizen_reception_subject') }}