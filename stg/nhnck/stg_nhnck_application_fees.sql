/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_fees
* Program name: Staging NHNCK.APPLICATION_FEES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (7 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(application_id AS bigint)  AS application_id
    , CAST(professional_id AS bigint) AS professional_id
    , CAST(fee_type AS bigint)        AS fee_type
    , CAST(content AS string)         AS content
    , CAST(note AS string)            AS note
    , CAST(status AS bigint)          AS status
    , CAST(request_date AS date)      AS request_date
    , CAST(payment_date AS date)      AS payment_date
    , CAST(expiry_date AS date)       AS expiry_date
    , CAST(fee AS decimal(18,2))      AS fee
    , CAST(file_path AS string)       AS file_path
    , CAST(created_by AS bigint)      AS created_by
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_by AS bigint)      AS updated_by
    , CAST(updated_at AS timestamp)   AS updated_at
FROM {{ source('source_nhnck', 'raw_application_fees') }}