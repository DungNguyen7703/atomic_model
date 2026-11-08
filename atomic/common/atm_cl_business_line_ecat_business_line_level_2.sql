/*
*--------------------------------------------------------------------*
* Program code: atm_cl_business_line
* Program name: Atomic Classification Business Line ECAT.BUSINESS_LINE_LEVEL_2
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH bu_li_le_2 AS (
    SELECT
        code
        , name
        , parent_line_id
        , display_label
        , effective
        , active
        , deleted
        , effective_start_date
        , effective_end_date
        , version
        , active_reason
        , deleted_reason
    FROM {{ ref('ods_ecat_business_line_level_2') }}
)

SELECT
    {{ generate_surrogate_key_bigint('ECAT_BUSINESS_LINE_LEVEL_2', "bu_li_le_2.code") }}             AS cl_business_line_id
    , CAST('ECAT_BUSINESS_LINE_LEVEL_2' AS string)                                                   AS src_stm_code
    , CAST('LEVEL_2' AS string)                                                                      AS cl_business_line_level_code
    , CAST(bu_li_le_2.code AS string)                                                                AS cl_business_line_code
    , CAST(bu_li_le_2.name AS string)                                                                AS cl_business_line_nm
    , {{ generate_surrogate_key_bigint('ECAT_BUSINESS_LINE_LEVEL_2', "bu_li_le_2.parent_line_id") }} AS parent_cl_business_line_id
    , CAST(bu_li_le_2.parent_line_id AS string)                                                      AS parent_cl_business_line_code
    , CAST(bu_li_le_2.display_label AS string)                                                       AS display_label
    , CAST(bu_li_le_2.effective AS int)                                                              AS effective_ind
    , CAST(bu_li_le_2.active AS int)                                                                 AS active_ind
    , CAST(bu_li_le_2.deleted AS int)                                                                AS deleted_ind
    , CAST(bu_li_le_2.effective_start_date AS timestamp)                                             AS effective_start_dt
    , CAST(bu_li_le_2.effective_end_date AS timestamp)                                               AS effective_end_dt
    , CAST(bu_li_le_2.version AS int)                                                                AS version_nbr
    , CAST(bu_li_le_2.active_reason AS string)                                                       AS active_reason
    , CAST(bu_li_le_2.deleted_reason AS string)                                                      AS deleted_reason
FROM bu_li_le_2