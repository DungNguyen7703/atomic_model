-- [FIRST-TIME] ft_dtm_opr_public_company_insider_ownership: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_opr_public_company_insider_ownership (config ft_target='opr_public_company_insider_ownership', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_public_company_insider_ownership
* Program name: Dtm Opr Public Company Insider Ownership
* Created by: tuan.nguyenvanb
* Created date: 2026-10-01
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-01		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_opr_public_company_insider_
*                                       ownership_IDS_COMPANY_ENTITY_ROLE.csv, GSTT Nhom 35 -
*                                       K_GSTT_354-358] Danh muc NGUOI NOI BO cua cong ty dai chung
*                                       (Operational, current-state, 1 dong / Cong ty x Nguoi noi bo).
*                                       - Driving: atm_pc_entity_role (role_tp_code = 'NNB').
*                                       - So huu: ban ghi pc_shareholding MOI NHAT / (cong ty, phap nhan).
*                                       - position_code / position_nm: ARRAY (nhieu chuc vu / nguoi noi bo),
*                                         position_nm tra cuu atm_cl_value (schema_code = 'IDS_POSITION').
*                                       [GIA DINH / LUU Y]
*                                       (1) LLD noi chuc vu chi qua legal_entity_id; O_GSTT_55 ghi nhan can
*                                           them pc_id. Code NOI THEM pc_id (legal_entity_position.pc_id =
*                                           pc_entity_role.pc_id) de khong lay chuc vu cua cong ty KHAC.
*                                       (2) atm_cl_value hien CHUA co du lieu scheme IDS_POSITION (chi co
*                                           MRMS_RISK_INDICATOR_CATEGORY) -> position_nm se RONG cho toi
*                                           khi atomic cl_value duoc bo sung nhom IDS_POSITION
*                                           (nguon IDS.LOOKUP_VALUES, LOOKUP_GROUP = 'POSITION').
*                                       (3) Mang sap xep (sort_array) de hash scd4a on dinh giua cac lan chay.
* 2026-10-08		tuan.nguyenvanb		[BACKFILL-UAT-NEW] TAM THOI: doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
*                                       Dong goc duoc giu o dang comment BACKFILL-UAT-ORIG. Chuyen che do daily bang dbt/first_time_mode.py [BACKFILL-UAT-NEW]
*                                       de tra ve nguyen ban sau khi chay xong du lieu 1 nam. [BACKFILL-UAT-NEW]
* 2026-10-17		tuan.nguyenvanb		[FIRST-TIME] ft_hstr_by_day: nguon IDS khong co lich su -> moi ngay giao dich 1 snapshot tu bang MAIN atomic, loc effective_from/to theo ngay snapshot, them cot ds_snpst_dt cuoi.
*--------------------------------------------------------------------*
*/

WITH cal AS (
    SELECT DISTINCT ds_snpst_dt   -- [FIRST-TIME 2026-10-17] lich ngay giao dich (nguon IDS khong co lich su -> lap trang thai hien tai theo tung ngay)
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
),

pc_en_ro AS (
    SELECT
        pc_entity_role_code,
        pc_id,
        pc_code,
        legal_entity_id,
        legal_entity_code,
        src_stm_code,
        effective_from_dt,
        effective_to_dt,
        cal.ds_snpst_dt
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_pc_entity_role') }}_hstr
    FROM {{ ref('atm_pc_entity_role') }}   -- [BACKFILL-UAT-NEW]
    CROSS JOIN cal   -- [FIRST-TIME 2026-10-17] moi ngay giao dich 1 snapshot
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND ds_rcrd_st = 'ACTIVE'
    WHERE ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND src_stm_code = 'IDS_COMPANY_ENTITY_ROLE'
        AND role_tp_code = 'NNB'
        AND (effective_from_dt IS NULL OR effective_from_dt <= cal.ds_snpst_dt)   -- [FIRST-TIME 2026-10-17] theo ngay snapshot thay vi etl_date
        AND (effective_to_dt   IS NULL OR effective_to_dt   >= cal.ds_snpst_dt)
),

pu_co AS (
    SELECT
        pc_id,
        equity_ticker_symbol
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_public_company') }}_hstr
    FROM {{ ref('atm_public_company') }}   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND ds_rcrd_st = 'ACTIVE'
    WHERE ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
),

le_en AS (
    SELECT
        legal_entity_id,
        legal_entity_nm
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_legal_entity') }}_hstr
    FROM {{ ref('atm_legal_entity') }}   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND ds_rcrd_st = 'ACTIVE'
    WHERE ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND src_stm_code = 'IDS_LEGAL_ENTITIES'
),

pc_sh_ranked AS (
    SELECT
        pc_id,
        legal_entity_id,
        ownership_quantity,
        ownership_ratio_percentage,
        ownership_dt,
        ROW_NUMBER() OVER (
            PARTITION BY pc_id, legal_entity_id
            ORDER BY ownership_dt DESC NULLS LAST, data_updated_dt DESC NULLS LAST
        ) AS rn
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_pc_shareholding') }}_hstr
    FROM {{ ref('atm_pc_shareholding') }}   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND ds_rcrd_st = 'ACTIVE'
    WHERE ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND src_stm_code = 'IDS_COMPANY_SHAREHOLDING'
        AND deleted_indicator = 0
),

pc_sh AS (
    SELECT
        pc_id,
        legal_entity_id,
        ownership_quantity,
        ownership_ratio_percentage,
        ownership_dt
    FROM pc_sh_ranked
    WHERE rn = 1
),

le_po AS (
    SELECT
        legal_entity_id,
        pc_id,
        position_code
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_legal_entity_position') }}_hstr
    FROM {{ ref('atm_legal_entity_position') }}   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND ds_rcrd_st = 'ACTIVE'
    WHERE ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND src_stm_code = 'IDS_POSITIONS'
        AND deleted_indicator = 0
),

cl_po AS (
    SELECT
        cl_code,
        cl_nm
    FROM atomic.uat_atm.cl_value
    WHERE schema_code = 'IDS_POSITION'
        AND ds_rcrd_st = 'ACTIVE'
),

position_agg AS (
    SELECT
        pc_en_ro.pc_entity_role_code,
        pc_en_ro.ds_snpst_dt,
        sort_array(collect_set(le_po.position_code)) AS position_code,
        sort_array(collect_set(cl_po.cl_nm))         AS position_nm
    FROM pc_en_ro
    LEFT JOIN le_po
        ON le_po.legal_entity_id = pc_en_ro.legal_entity_id
        AND le_po.pc_id = pc_en_ro.pc_id
    LEFT JOIN cl_po
        ON cl_po.cl_code = le_po.position_code
    GROUP BY pc_en_ro.pc_entity_role_code, pc_en_ro.ds_snpst_dt
)

SELECT
    CAST(pc_en_ro.pc_entity_role_code AS string)                  AS public_company_entity_role_code,
    CAST(pc_en_ro.pc_code AS string)                              AS public_company_code,
    CAST(pc_en_ro.legal_entity_code AS string)                    AS legal_entity_code,
    CAST(pu_co.equity_ticker_symbol AS string)                    AS equity_ticker_symbol,
    CAST(le_en.legal_entity_nm AS string)                         AS legal_entity_nm,
    CAST(pc_sh.ownership_quantity AS bigint)                      AS ownership_quantity,
    CAST(pc_sh.ownership_ratio_percentage AS decimal(5,2))        AS ownership_ratio_percentage,
    CAST(pc_sh.ownership_dt AS date)                              AS ownership_dt,
    COALESCE(position_agg.position_code, array())                 AS position_code,
    COALESCE(position_agg.position_nm, array())                   AS position_nm,
    CAST(pc_en_ro.src_stm_code AS string)                         AS src_stm_code,
    CAST(pc_en_ro.ds_snpst_dt AS date)                            AS ds_snpst_dt   -- [FIRST-TIME 2026-10-17] ngay snapshot (ft_hstr_by_day)
FROM pc_en_ro
INNER JOIN pu_co
    ON pu_co.pc_id = pc_en_ro.pc_id
INNER JOIN le_en
    ON le_en.legal_entity_id = pc_en_ro.legal_entity_id
LEFT JOIN pc_sh
    ON pc_sh.pc_id = pc_en_ro.pc_id
    AND pc_sh.legal_entity_id = pc_en_ro.legal_entity_id
LEFT JOIN position_agg
    ON position_agg.pc_entity_role_code = pc_en_ro.pc_entity_role_code
    AND position_agg.ds_snpst_dt = pc_en_ro.ds_snpst_dt
