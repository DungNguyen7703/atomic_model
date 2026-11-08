/*
*--------------------------------------------------------------------*
* Program code: atm_inspection_conclusion
* Program name: Atomic Inspection Conclusion
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH in_co AS (
    SELECT
        id
        , inspection_team_id
        , conclusion_number
        , issued_date
        , announced_date
        , target_type
        , target_reference_id
        , target_name
        , content
        , recommendation
        , execution_status
        , execution_description
        , government_inspector_sent_date
    FROM {{ ref('ods_thanhtra_inspection_conclusion') }}
),

in_te AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_inspection_team') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_CONCLUSION', "in_co.id") }} AS inspection_conclusion_id
    , CAST(in_co.id AS string)                                                        AS inspection_conclusion_code
    , CAST('THANHTRA_INSPECTION_CONCLUSION' AS string)                                AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_TEAM', "in_te.code") }}   AS inspection_team_id
    , CAST(in_co.inspection_team_id AS string)                                        AS inspection_team_code
    , CAST(in_co.conclusion_number AS string)                                         AS conclusion_nbr
    , CAST(in_co.issued_date AS date)                                                 AS issued_dt
    , CAST(in_co.announced_date AS date)                                              AS announced_dt
    , CAST(in_co.target_type AS string)                                               AS target_tp_code
    , CAST(in_co.target_reference_id AS string)                                       AS target_reference_id
    , CAST(in_co.target_name AS string)                                               AS target_nm
    , CAST(in_co.content AS string)                                                   AS content
    , CAST(in_co.recommendation AS string)                                            AS recommendation
    , CAST(in_co.execution_status AS string)                                          AS execution_status_code
    , CAST(in_co.execution_description AS string)                                     AS execution_description
    , CAST(in_co.government_inspector_sent_date AS date)                              AS government_inspector_sent_dt
FROM in_co
    LEFT JOIN in_te ON in_co.INSPECTION_TEAM_ID = in_te.ID