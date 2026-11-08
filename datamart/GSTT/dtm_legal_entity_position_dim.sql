/*
*--------------------------------------------------------------------*
* Program code: dtm_legal_entity_position_dim
* Program name: Dtm Legal Entity Position Dim
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH le_en_po AS (
    SELECT
        legal_entity_position_code,
        position_code,
        appointment_dt,
        dismissal_dt,
        src_stm_code
    FROM {{ ref('atm_legal_entity_position') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_POSITIONS'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('IDS_POSITIONS', 'legal_entity_position_code') }} AS string) AS legal_entity_position_dim_id,
    CAST(legal_entity_position_code AS string)                      AS legal_entity_position_code,
    CAST(position_code AS string)                                   AS position_code,
    CAST(appointment_dt AS date)                                    AS appointment_dt,
    CAST(dismissal_dt AS date)                                      AS dismissal_dt,
    CAST(src_stm_code AS string)                                    AS src_stm_code
FROM le_en_po
