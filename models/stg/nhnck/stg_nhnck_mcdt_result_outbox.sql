/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_mcdt_result_outbox
* Program name: Staging NHNCK.MCDT_RESULT_OUTBOX
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (3 cot); kieu date sang timestamp (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                 AS id
    , CAST(application_id AS bigint)   AS application_id
    , CAST(sender_identity AS string)  AS sender_identity
    , CAST(status AS string)           AS status
    , CAST(attempts AS bigint)         AS attempts
    , CAST(next_retry_at AS timestamp) AS next_retry_at
    , CAST(last_error AS string)       AS last_error
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
FROM {{ source('source_nhnck', 'raw_mcdt_result_outbox') }}
