/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_notifications
* Program name: Staging NHNCK.NOTIFICATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (4 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)            AS id
    , CAST(action_type AS bigint) AS action_type
    , CAST(type AS bigint)        AS type
    , CAST(is_read AS int)        AS is_read
    , CAST(content AS string)     AS content
    , CAST(link AS string)        AS link
    , CAST(receiver_id AS bigint) AS receiver_id
    , CAST(sent_at AS timestamp)  AS sent_at
    , CAST(read_at AS timestamp)  AS read_at
FROM {{ source('source_nhnck', 'raw_notifications') }}