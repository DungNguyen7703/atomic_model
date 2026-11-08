-- [FIRST-TIME] ft_dtm_legal_entity_position_dim: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_legal_entity_position_dim (config ft_target='legal_entity_position_dim', macro macros/first_time).
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
* 2026-10-08		tuan.nguyenvanb		[BACKFILL-UAT-NEW] TAM THOI: doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
*                                       Dong goc duoc giu o dang comment BACKFILL-UAT-ORIG. Chuyen che do daily bang dbt/first_time_mode.py [BACKFILL-UAT-NEW]
*                                       de tra ve nguyen ban sau khi chay xong du lieu 1 nam. [BACKFILL-UAT-NEW]
* 2026-10-17		tuan.nguyenvanb		[FIRST-TIME] ft_hstr_by_day: nguon IDS khong co lich su -> lap trang thai hien tai (bang MAIN atomic) cho TUNG ngay giao dich, them cot ds_snpst_dt cuoi.
*--------------------------------------------------------------------*
*/

WITH cal AS (
    SELECT DISTINCT ds_snpst_dt   -- [FIRST-TIME 2026-10-17] lich ngay giao dich (nguon IDS khong co lich su -> lap trang thai hien tai theo tung ngay)
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
),

le_en_po AS (
    SELECT
        legal_entity_position_code,
        position_code,
        appointment_dt,
        dismissal_dt,
        src_stm_code
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_legal_entity_position') }}_hstr
    FROM {{ ref('atm_legal_entity_position') }}   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND ds_rcrd_st = 'ACTIVE'
    WHERE ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND src_stm_code = 'IDS_POSITIONS'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('IDS_POSITIONS', 'legal_entity_position_code') }} AS string) AS legal_entity_position_dim_id,
    CAST(legal_entity_position_code AS string)                      AS legal_entity_position_code,
    CAST(position_code AS string)                                   AS position_code,
    CAST(appointment_dt AS date)                                    AS appointment_dt,
    CAST(dismissal_dt AS date)                                      AS dismissal_dt,
    CAST(src_stm_code AS string)                                    AS src_stm_code,
    CAST(cal.ds_snpst_dt AS date)                                   AS ds_snpst_dt   -- [FIRST-TIME 2026-10-17] ngay snapshot (ft_hstr_by_day)
FROM le_en_po
CROSS JOIN cal
