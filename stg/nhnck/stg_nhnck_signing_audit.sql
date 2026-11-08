/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_signing_audit
* Program name: Staging NHNCK.SIGNING_AUDIT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): doi kieu cot id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(38,10))      AS id
    , CAST(session_id AS string)    AS session_id
    , CAST(action AS string)        AS action
    , CAST(user_ref AS string)      AS user_ref
    , CAST(document_path AS string) AS document_path
    , CAST(cert_serial AS string)   AS cert_serial
    , CAST(success AS int)          AS success
    , CAST(detail AS string)        AS detail
    , CAST(created_at AS timestamp) AS created_at
FROM {{ source('source_nhnck', 'raw_signing_audit') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= '{{ var("etl_date") }}'