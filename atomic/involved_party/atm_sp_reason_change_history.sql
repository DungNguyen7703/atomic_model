/*
*--------------------------------------------------------------------*
* Program code: atm_sp_reason_change_history
* Program name: Atomic Securities Practitioner Reason Change History
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pr_hi AS (
    SELECT
        id
        , professional_id
        , change_date
        , reason_update
    FROM {{ ref('ods_nhnck_professional_histories') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONAL_HISTORIES', "pr_hi.id") }}       AS sp_reason_change_history_id
    , CAST(pr_hi.id AS string)                                                            AS sp_reason_change_history_code
    , CAST('NHNCK_PROFESSIONAL_HISTORIES' AS string)                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "pr_hi.professional_id") }} AS sp_id
    , CAST(pr_hi.professional_id AS string)                                               AS sp_code
    , CAST(pr_hi.change_date AS date)                                                     AS change_dt
    , CAST(pr_hi.reason_update AS string)                                                 AS change_reason
FROM pr_hi