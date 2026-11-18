/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_histories
* Program name: Staging NHNCK.APPLICATION_HISTORIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (7 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)               AS id
    , CAST(application_id AS bigint) AS application_id
    , CAST(status_id AS bigint)      AS status_id
    , CAST(title AS string)          AS title
    , CAST(description AS string)    AS description
    , CAST(created_at AS timestamp)  AS created_at
    , CAST(sender_id AS bigint)      AS sender_id
    , CAST(receiver_id AS bigint)    AS receiver_id
    , CAST(receiver_name AS string)  AS receiver_name
    , CAST(is_rejected AS int)       AS is_rejected
    , CAST(feedback AS string)       AS feedback
    , CAST(updated_at AS timestamp)  AS updated_at
    , CAST(created_by AS bigint)     AS created_by
    , CAST(updated_by AS bigint)     AS updated_by
FROM {{ source('source_nhnck', 'raw_application_histories') }}