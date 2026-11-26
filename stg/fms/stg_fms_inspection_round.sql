/*
*--------------------------------------------------------------------*
* Program code: stg_fms_inspection_round
* Program name: Staging FMS.INSPECTION_ROUND
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-11-10		tuan.nguyenvanb		Dong bo theo DDL prod (drive-download ddl): kieu du lieu 5 cot; them cot data_source,thanh_tra_external_id.
* 2026-11-10		tuan.nguyenvanb		Dong bo theo DDL final (drive-download 2026-11-10): kieu du lieu 3 cot theo DDL final.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                   AS id
    , CAST(deleted AS int)                    AS deleted
    , CAST(object_type AS int)      AS object_type
    , CAST(other_object_name AS string)       AS other_object_name
    , CAST(inspection_year AS int)  AS inspection_year
    , CAST(start_date AS timestamp)           AS start_date
    , CAST(end_date AS timestamp)             AS end_date
    , CAST(decision_no AS string)             AS decision_no
    , CAST(decision_date AS timestamp)        AS decision_date
    , CAST(period_from AS timestamp)          AS period_from
    , CAST(period_to AS timestamp)            AS period_to
    , CAST(inspection_kind AS bigint)  AS inspection_kind
    , CAST(date_created AS timestamp)         AS date_created
    , CAST(created_by AS string)              AS created_by
    , CAST(date_modified AS timestamp)        AS date_modified
    , CAST(modify_by AS string)               AS modify_by
    , CAST(data_source AS string)             AS data_source
    , CAST(thanh_tra_external_id AS string)   AS thanh_tra_external_id
FROM {{ source('source_fms', 'raw_inspection_round') }}