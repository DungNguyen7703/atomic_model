<<<<<<< HEAD
/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_decisions
* Program name: Staging NHNCK.DECISIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (5 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                 AS id
    , CAST(decision_number AS string)  AS decision_number
    , CAST(title AS string)            AS title
    , CAST(reference AS string)        AS reference
    , CAST(decision_content AS string) AS decision_content
    , CAST(signed_date AS date)        AS signed_date
    , CAST(signatory AS string)        AS signatory
    , CAST(position AS string)         AS position
    , CAST(decision_unit AS string)    AS decision_unit
    , CAST(file_name AS string)        AS file_name
    , CAST(file_path AS string)        AS file_path
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(created_by AS bigint)       AS created_by
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(decision_type_id AS bigint) AS decision_type_id
    , CAST(status AS bigint)           AS status
    , CAST(content AS string)          AS content
    , CAST(is_active AS int)           AS is_active
    , CAST(updated_by AS bigint)       AS updated_by
=======
/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_decisions
* Program name: Staging NHNCK.DECISIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                 AS id
    , CAST(decision_number AS string)  AS decision_number
    , CAST(title AS string)            AS title
    , CAST(reference AS string)        AS reference
    , CAST(decision_content AS string) AS decision_content
    , CAST(signed_date AS date)        AS signed_date
    , CAST(signatory AS string)        AS signatory
    , CAST(position AS string)         AS position
    , CAST(decision_unit AS string)    AS decision_unit
    , CAST(file_name AS string)        AS file_name
    , CAST(file_path AS string)        AS file_path
    , CAST(created_at AS date)         AS created_at
    , CAST(created_by AS bigint)       AS created_by
    , CAST(updated_at AS date)         AS updated_at
    , CAST(decision_type_id AS bigint) AS decision_type_id
    , CAST(status AS bigint)           AS status
    , CAST(content AS string)          AS content
    , CAST(is_active AS int)           AS is_active
    , CAST(updated_by AS bigint)       AS updated_by
>>>>>>> 16e7f257572ea37da39d62b83c82c5e752ece640
FROM {{ source('source_nhnck', 'raw_decisions') }}