/*
*--------------------------------------------------------------------*
* Program code: dtm_examination_team_target_dim
* Program name: Examination Team Target Dimension
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ex_te_tg AS (
    SELECT
        examination_team_target_code,
        target_tp_code,
        src_stm_code
    FROM {{ ref('atm_examination_team_target') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_EXAMINATION_TEAM_TARGET'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_TEAM_TARGET', 'ex_te_tg.examination_team_target_code') }} AS string) AS examination_team_target_dim_id,
    CAST(ex_te_tg.examination_team_target_code AS string)                     AS examination_team_target_code,
    CAST(ex_te_tg.target_tp_code AS string)                                   AS target_tp_code,
    CAST(ex_te_tg.src_stm_code AS string)                                     AS src_stm_code
FROM ex_te_tg
