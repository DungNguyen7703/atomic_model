/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_conversion_practice_history_confirms
* Program name: Staging NHNCK.CONVERSION_PRACTICE_HISTORY_CONFIRMS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (7 cot); kieu date sang timestamp (4 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                       AS id
    , CAST(request_id AS string)             AS request_id
    , CAST(conversion_request_id AS bigint)  AS conversion_request_id
    , CAST(source_type AS bigint)            AS source_type
    , CAST(organization_id AS bigint)        AS organization_id
    , CAST(identity_number AS string)        AS identity_number
    , CAST(full_name AS string)              AS full_name
    , CAST(declared_work_history AS string)  AS declared_work_history
    , CAST(status AS bigint)                 AS status
    , CAST(result AS string)                 AS result
    , CAST(responded_by AS string)           AS responded_by
    , CAST(responded_at AS timestamp)        AS responded_at
    , CAST(corrected_work_history AS string) AS corrected_work_history
    , CAST(reason AS string)                 AS reason
    , CAST(requested_by AS string)           AS requested_by
    , CAST(requested_at AS timestamp)        AS requested_at
    , CAST(created_by AS bigint)             AS created_by
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(updated_by AS bigint)             AS updated_by
    , CAST(updated_at AS timestamp)          AS updated_at
FROM {{ source('source_nhnck', 'raw_conversion_practice_history_confirms') }}
