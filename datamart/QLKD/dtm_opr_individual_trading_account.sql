/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_individual_trading_account
* Program name: Dtm Opr Individual Trading Account
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-29		tuan.nguyenvanb		[SUA theo dung LLD, ket qua ra soat doi chieu Mapping]
*                                       Sua ten cot sai src_rcrd_isrt_tms -> src_record_insert_tms
*                                       (dung ten cot that atm_sc_shareholder sinh ra, macro
*                                       scd4a khong doi ten cot). Bo sung shareholder_tp_code
*                                       (LLD dong 7, direct tu sc_shareholder, co san trong
*                                       atomic). Bo sung sc_short_nm (LLD dong 3, JOIN
*                                       atm_securities_company_hstr theo sc_id, pattern giong
*                                       dtm_securities_company_dim.sql). Bo sung
*                                       individual_identification_nbr (LLD dong 4, JOIN
*                                       atm_ip_alternative_identification_hstr theo ip_id =
*                                       sc_shareholder_id, dieu kien identification_tp_code =
*                                       'IDENTIFICATION' dung theo van ban LLD - LUU Y: atomic
*                                       nguon SCMS_SC_FIRM_SHAREHOLDER hien chi co gia tri
*                                       'LEGACY_NATIONAL_ID', chua co 'IDENTIFICATION', nen cot
*                                       nay se luon NULL cho toi khi BA/atomic team xac nhan lai
*                                       gia tri dung - da xac nhan voi user 2026-10-29: giu dung
*                                       literal LLD, khong tu doi).
*--------------------------------------------------------------------*
*/

WITH se_co_sh AS (
    SELECT
        sc_id,
        sc_shareholder_id,
        sc_shareholder_code,
        sc_code,
        trading_account,
        shareholder_nm,
        shareholder_tp_code,
        src_stm_code,
        src_record_insert_tms
    FROM {{ ref('atm_sc_shareholder') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_SHAREHOLDER'
),

se_co AS (
    SELECT
        sc_id,
        sc_short_nm
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
),

ip_al_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'IDENTIFICATION'
        AND src_stm_code = 'SCMS_SC_FIRM_SHAREHOLDER'
)

SELECT
    CAST(se_co_sh.sc_shareholder_code AS string)       AS sc_shareholder_code,
    CAST(se_co_sh.sc_code AS string)                    AS sc_code,
    CAST(se_co.sc_short_nm AS string)                   AS sc_short_nm,
    CAST(ip_al_id.identification_nbr AS string)         AS individual_identification_nbr,
    CAST(se_co_sh.trading_account AS string)            AS trading_account,
    CAST(se_co_sh.shareholder_nm AS string)             AS shareholder_nm,
    CAST(se_co_sh.shareholder_tp_code AS string)        AS shareholder_tp_code,
    CAST(se_co_sh.src_stm_code AS string)               AS src_stm_code,
    CAST(se_co_sh.src_record_insert_tms AS date)        AS created_dt
FROM se_co_sh
LEFT JOIN se_co
    ON  se_co.sc_id = se_co_sh.sc_id
LEFT JOIN ip_al_id
    ON  ip_al_id.ip_id = se_co_sh.sc_shareholder_id
