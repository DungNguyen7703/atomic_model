/*
*--------------------------------------------------------------------*
* Program code: dtm_inspection_team_target_dim
* Program name: Dtm Inspection Team Target Dim
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH in_te_ta AS (
    SELECT inspection_team_target_code, target_tp_code, src_stm_code
    FROM {{ ref('atm_inspection_team_target') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM_TARGET'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_TEAM_TARGET', 'in_te_ta.inspection_team_target_code') }} AS string) AS inspection_team_target_dim_id,
    CAST(in_te_ta.inspection_team_target_code AS string)                     AS inspection_team_target_code,
    CAST(in_te_ta.target_tp_code AS string)                                  AS target_tp_code,
    CAST(in_te_ta.src_stm_code AS string)                                    AS src_stm_code
FROM in_te_ta
