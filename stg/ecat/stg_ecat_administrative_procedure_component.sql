/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_administrative_procedure_component
* Program name: Staging ECAT.ADMINISTRATIVE_PROCEDURE_COMPONENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(code AS string)                    AS code
    , CAST(name AS string)                    AS name
    , CAST(procedure_type AS string)          AS procedure_type
    , CAST(original_quantity AS bigint)       AS original_quantity
    , CAST(copy_quantity AS bigint)           AS copy_quantity
    , CAST(display_order AS bigint)           AS display_order
    , CAST(description AS string)             AS description
    , CAST(active AS int)                     AS active
    , CAST(active_reason AS string)           AS active_reason
    , CAST(deleted AS int)                    AS deleted
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(version AS int)                    AS version
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(old_id AS string)                  AS old_id
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(stable_id AS string)               AS stable_id
    , CAST(required AS int)                   AS required
    , CAST(e_form AS int)                     AS e_form
    , CAST(effective AS int)                  AS effective
FROM {{ source('source_ecat', 'raw_administrative_procedure_component') }}