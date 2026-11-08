/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_securities_company_financial_report_hist
* Program name: Dtm Opr Securities Company Financial Report Hist
* Created by: tuan.nguyenvanb
* Created date: 2026-09-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-19		tuan.nguyenvanb		[MOI, theo LLD QLKD Nhom 24] Sinh moi -
*                                       Securities Company Financial Report
*                                       History.
*                                       [CAP NHAT 2026-10-02] Nguon atm_sc_
*                                       report_input_value DA CO trong atomic
*                                       layer (xem models/atomic/documentation/
*                                       atm_sc_report_input_value.sql) - model
*                                       nay co the dbt run duoc, nhung khoa
*                                       join giua sc_report_input_value/
*                                       sc_periodic_report/sc_report_input_
*                                       submission van can BA xac nhan lai
*                                       (xem ghi chu ben duoi).
*                                       [SUA 2026-09-18] Bo sung rpt_code
*                                       vao NK + khoa hash PK vi BA dua them
*                                       BCTC hop nhat vao cung nguon - cung
*                                       (CTCK, ky) nay co the co ca ban hop
*                                       nhat lan rieng le.
*                                       [RANG BUOC ETL 2026-09-18] Nguon tra
*                                       ve moi version - khu trung theo
*                                       (sc_code, rpt_year, rpt_period,
*                                       rpt_code) giu ban nop moi nhat theo
*                                       submission_dt.
*                                       roa_rate/roe_rate: LLD ghi "computed"
*                                       nhung khong co cong thuc/cell_id cu
*                                       the - tam de NULL, CAN BO SUNG cong
*                                       thuc chinh thuc tu BA.
* 2026-10-19		claude				[SUA theo LLD, da xac nhan khoa join
*                                       that - ap dung chung 1 chain voi
*                                       dtm_fct_securities_company_financial_
*                                       structure_snpst]: thay CROSS JOIN/
*                                       JOIN ON 1=1 bang INNER JOIN
*                                       sc_report_input_submission ON
*                                       sc_rpt_input_submission_id, INNER
*                                       JOIN sc_periodic_report ON ref_id =
*                                       sc_periodic_rpt_code AND ref_tp_code =
*                                       'BAO_CAO_DINH_KY', INNER JOIN
*                                       securities_company ON sc_id, JOIN
*                                       sc_report de lay dung rpt_code nghiep
*                                       vu (khong phai sc_rpt_code - ID ky
*                                       thuat form_report_id). Sua ten cot
*                                       item_val -> cell_val (dung ten that
*                                       cua atm_sc_report_input_value). Bo
*                                       sung cot preferred_report_ind theo
*                                       dung window function LLD.
* 2026-10-24		claude			[BO SUNG theo dung LLD mapping - moi cot FK/DD]
*                                       Them dieu kien LLD yeu cau tren
*                                       sc_report_input_submission: data_dt =
*                                       MAX(data_dt) cua cung sc_rpt_input_
*                                       submission_id - co lap version hien
*                                       hanh, tranh nhan dong khi Atomic APPEND
*                                       ban ghi moi luc nop lai (O_QLKD_55).
*                                       Truoc day model khong co dieu kien
*                                       data_dt nao.
*                                       [PHU THUOC ATOMIC - CHUA THE CHAY]
*                                       atm_sc_report_input_submission va
*                                       atm_sc_report_input_value HIEN CHUA
*                                       SELECT cot data_dt trong output - model
*                                       se loi compile (column not found) cho
*                                       toi khi Atomic duoc bo sung cot nay.
*                                       Quyet dinh tam thoi da duoc user xac
*                                       nhan 2026-10-24: sua datamart truoc
*                                       theo dung LLD, bo sung atomic sau.
* 2026-10-26		claude			[SUA theo dung LLD - ket qua ra soat doi
*                                       chieu Mapping] (1) Sua cell_id SAI cho
*                                       revenue/profit: revenue_amt tu KQ001/
*                                       DT001 sang TS031 (ca BCTCHN va BCTCRL,
*                                       co guard rpt_code IN ('BCTCHN','BCTCRL')
*                                       de tranh nhan nham o cua bieu mau khac);
*                                       profit_after_tax_amt tu KQ019/LN001
*                                       sang TS121 (BCTCHN) / TS119 (BCTCRL) -
*                                       moi bieu mau co CASE WHEN rieng dung
*                                       LLD dong 10. (2) Bo sung cong thuc
*                                       chinh thuc cho roa_rate/roe_rate theo
*                                       LLD dong 11/12 (BA 2026-09-18): ROA =
*                                       LNST / Tong tai san binh quan (dau ky +
*                                       cuoi ky)/2 * 100, ROE = LNST / Von CSH
*                                       binh quan (dau ky + cuoi ky)/2 * 100;
*                                       thieu dau ky thi lay cuoi ky. BCTCHN:
*                                       TS cuoi TS273, TS dau TS274, VCSH cuoi
*                                       TS359, VCSH dau TS360. BCTCRL: TS cuoi
*                                       TS135 (du phong TS133), TS dau TS136
*                                       (du phong TS134), VCSH cuoi TS223 (du
*                                       phong TS221), VCSH dau TS224 (du phong
*                                       TS222). Khong con hard-code NULL.
* 2026-10-28		claude			[BO SUNG theo dung LLD mapping, O_QLKD_63]
*                                       Them CTE sc_rpt_deep_cfg_dedup (SELECT
*                                       DISTINCT sc_rpt_id, sheet_id, sheet_code
*                                       FROM atm_sc_report_deep_config) va LEFT
*                                       JOIN vao CTE joined theo (sc_rpt_id,
*                                       sheet_id). Them dieu kien sheet_cfg.
*                                       sheet_code vao tung CASE WHEN cua 13 cot
*                                       do: doanh thu/LNST (revenue_cell_amt,
*                                       profit_cell_amt) loc sheet '06622'
*                                       (BCTCHN) / '06610' (BCTCRL); tong tai
*                                       san va VCSH dau/cuoi ky loc sheet '06620'
*                                       (BCTCHN) / '06608' (BCTCRL). Ly do: cung
*                                       mot ma o (cell_id) xuat hien o nhieu
*                                       sheet khac nhau cua cung bieu mau voi
*                                       nghia khac nhau - truoc day khong loc
*                                       sheet nen bi cong/lan gia tri sai (BA
*                                       phat hien lech so Staging vs ClickHouse,
*                                       issue 27/10 #261-#265).
* 2026-10-28		claude			[SUA theo dung LLD mapping dong 15, O_QLKD_65(3)]
*                                       Doi tieu chi khu trung ban nop tu
*                                       MAX(submission_dt) sang MAX(CAST(
*                                       sc_rpt_input_submission_code AS bigint))
*                                       - dung yeu cau LLD "khu trung theo ... ma
*                                       nop (sc_rpt_input_submission_code, ep
*                                       BIGINT) lon nhat" (nhu SQL BA ORDER BY ID
*                                       DESC va dung cung co che da ap dung o
*                                       dtm_fct_securities_company_financial_
*                                       structure_snpst, CTE sc_rpt_in_su_dedup).
*                                       Them cot sc_rpt_input_submission_code vao
*                                       CTE sc_rpt_in_su (nguon atm_sc_report_
*                                       input_submission), truyen qua joined toi
*                                       agg. Grain/cau truc cot output khong doi.
*--------------------------------------------------------------------*
*/

WITH sc_rpt_in_va AS (
    SELECT
        cell_id,
        cell_val,
        sheet_id,
        sc_rpt_input_submission_id,
        src_stm_code
    FROM {{ ref('atm_sc_report_input_value') }}
    WHERE src_stm_code = 'SCMS_REPORT_INPUT_CELL_VALUE'
),

sc_rpt_in_su AS (
    SELECT
        sc_rpt_input_submission_id,
        sc_rpt_id,
        ref_id,
        ref_tp_code,
        sc_rpt_input_submission_code
    FROM {{ ref('atm_sc_report_input_submission') }} sc_rpt_in_su
    WHERE sc_rpt_in_su.data_dt = (
        SELECT MAX(sub_ver.data_dt)
        FROM {{ ref('atm_sc_report_input_submission') }} sub_ver
        WHERE sub_ver.sc_rpt_input_submission_id = sc_rpt_in_su.sc_rpt_input_submission_id
    )
),

sc_rpt AS (
    SELECT
        sc_rpt_id,
        rpt_code
    FROM {{ ref('atm_sc_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
),

sc_rpt_deep_cfg_dedup AS (
    SELECT DISTINCT
        sc_rpt_id,
        sheet_id,
        sheet_code
    FROM {{ ref('atm_sc_report_deep_config') }}
),

sc_pe_rpt AS (
    SELECT
        sc_id,
        sc_code,
        sc_periodic_rpt_code,
        rpt_year,
        rpt_period,
        period,
        sent_tms,
        rpt_submission_status_code
    FROM {{ ref('atm_sc_periodic_report') }}
    WHERE src_stm_code = 'SCMS_SC_FIRM_PERIODIC_REPORT'
        AND ds_rcrd_st = 'ACTIVE'
),

se_co AS (
    SELECT
        sc_id,
        sc_code,
        sc_nm
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
),

joined AS (
    SELECT
        se_co.sc_code                                                       AS sc_code,
        se_co.sc_nm                                                         AS sc_nm,
        sc_pe_rpt.rpt_year                                                  AS rpt_year,
        sc_pe_rpt.rpt_period                                                AS rpt_period,
        sc_rpt.rpt_code                                                     AS rpt_code,
        sc_pe_rpt.period                                                    AS period_nbr,
        CASE WHEN sc_rpt.rpt_code = 'BCTCHN' AND sheet_cfg.sheet_code = '06622' AND sc_rpt_in_va.cell_id = 'TS031' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2))
             WHEN sc_rpt.rpt_code = 'BCTCRL' AND sheet_cfg.sheet_code = '06610' AND sc_rpt_in_va.cell_id = 'TS031' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS revenue_cell_amt,
        CASE WHEN sc_rpt.rpt_code = 'BCTCHN' AND sheet_cfg.sheet_code = '06622' AND sc_rpt_in_va.cell_id = 'TS121' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2))
             WHEN sc_rpt.rpt_code = 'BCTCRL' AND sheet_cfg.sheet_code = '06610' AND sc_rpt_in_va.cell_id = 'TS119' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS profit_cell_amt,
        CASE WHEN sc_rpt.rpt_code = 'BCTCHN' AND sheet_cfg.sheet_code = '06620' AND sc_rpt_in_va.cell_id = 'TS273' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS asset_end_bctchn_amt,
        CASE WHEN sc_rpt.rpt_code = 'BCTCRL' AND sheet_cfg.sheet_code = '06608' AND sc_rpt_in_va.cell_id = 'TS135' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS asset_end_bctcrl_ts135_amt,
        CASE WHEN sc_rpt.rpt_code = 'BCTCRL' AND sheet_cfg.sheet_code = '06608' AND sc_rpt_in_va.cell_id = 'TS133' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS asset_end_bctcrl_ts133_amt,
        CASE WHEN sc_rpt.rpt_code = 'BCTCHN' AND sheet_cfg.sheet_code = '06620' AND sc_rpt_in_va.cell_id = 'TS274' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS asset_begin_bctchn_amt,
        CASE WHEN sc_rpt.rpt_code = 'BCTCRL' AND sheet_cfg.sheet_code = '06608' AND sc_rpt_in_va.cell_id = 'TS136' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS asset_begin_bctcrl_ts136_amt,
        CASE WHEN sc_rpt.rpt_code = 'BCTCRL' AND sheet_cfg.sheet_code = '06608' AND sc_rpt_in_va.cell_id = 'TS134' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS asset_begin_bctcrl_ts134_amt,
        CASE WHEN sc_rpt.rpt_code = 'BCTCHN' AND sheet_cfg.sheet_code = '06620' AND sc_rpt_in_va.cell_id = 'TS359' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS equity_end_bctchn_amt,
        CASE WHEN sc_rpt.rpt_code = 'BCTCRL' AND sheet_cfg.sheet_code = '06608' AND sc_rpt_in_va.cell_id = 'TS223' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS equity_end_bctcrl_ts223_amt,
        CASE WHEN sc_rpt.rpt_code = 'BCTCRL' AND sheet_cfg.sheet_code = '06608' AND sc_rpt_in_va.cell_id = 'TS221' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS equity_end_bctcrl_ts221_amt,
        CASE WHEN sc_rpt.rpt_code = 'BCTCHN' AND sheet_cfg.sheet_code = '06620' AND sc_rpt_in_va.cell_id = 'TS360' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS equity_begin_bctchn_amt,
        CASE WHEN sc_rpt.rpt_code = 'BCTCRL' AND sheet_cfg.sheet_code = '06608' AND sc_rpt_in_va.cell_id = 'TS224' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS equity_begin_bctcrl_ts224_amt,
        CASE WHEN sc_rpt.rpt_code = 'BCTCRL' AND sheet_cfg.sheet_code = '06608' AND sc_rpt_in_va.cell_id = 'TS222' THEN TRY_CAST(sc_rpt_in_va.cell_val AS decimal(23,2)) END AS equity_begin_bctcrl_ts222_amt,
        CAST(sc_pe_rpt.sent_tms AS date)                                    AS submission_dt,
        sc_pe_rpt.rpt_submission_status_code                                AS submission_status_code,
        sc_rpt_in_va.src_stm_code                                           AS src_stm_code,
        sc_rpt_in_su.sc_rpt_input_submission_code                          AS sc_rpt_input_submission_code,
        CASE
            WHEN sc_rpt.rpt_code = 'BCTCRL'
                AND MAX(CASE WHEN sc_rpt.rpt_code = 'BCTCHN' AND sc_pe_rpt.rpt_submission_status_code IN ('1','2') THEN 1 ELSE 0 END)
                    OVER (PARTITION BY sc_pe_rpt.sc_code, sc_pe_rpt.rpt_year, sc_pe_rpt.rpt_period, sc_pe_rpt.period) = 1
            THEN '0'
            ELSE '1'
        END AS preferred_report_ind
    FROM sc_rpt_in_va
    INNER JOIN sc_rpt_in_su
        ON  sc_rpt_in_su.sc_rpt_input_submission_id = sc_rpt_in_va.sc_rpt_input_submission_id
    INNER JOIN sc_pe_rpt
        ON  sc_pe_rpt.sc_periodic_rpt_code = sc_rpt_in_su.ref_id
        AND sc_rpt_in_su.ref_tp_code = 'BAO_CAO_DINH_KY'
    INNER JOIN se_co
        ON  se_co.sc_id = sc_pe_rpt.sc_id
    JOIN sc_rpt
        ON  sc_rpt.sc_rpt_id = sc_rpt_in_su.sc_rpt_id
    LEFT JOIN sc_rpt_deep_cfg_dedup sheet_cfg
        ON  sheet_cfg.sc_rpt_id = sc_rpt.sc_rpt_id
        AND sheet_cfg.sheet_id = sc_rpt_in_va.sheet_id
),

agg AS (
    SELECT
        sc_code,
        sc_nm,
        rpt_year,
        rpt_period,
        rpt_code,
        period_nbr,
        preferred_report_ind,
        SUM(revenue_cell_amt) / 1000000000 AS revenue_amt,
        SUM(profit_cell_amt) / 1000000000  AS profit_after_tax_amt,
        COALESCE(SUM(asset_end_bctchn_amt), COALESCE(SUM(asset_end_bctcrl_ts135_amt), SUM(asset_end_bctcrl_ts133_amt)))     AS asset_end_amt,
        COALESCE(SUM(asset_begin_bctchn_amt), COALESCE(SUM(asset_begin_bctcrl_ts136_amt), SUM(asset_begin_bctcrl_ts134_amt))) AS asset_begin_amt,
        COALESCE(SUM(equity_end_bctchn_amt), COALESCE(SUM(equity_end_bctcrl_ts223_amt), SUM(equity_end_bctcrl_ts221_amt)))   AS equity_end_amt,
        COALESCE(SUM(equity_begin_bctchn_amt), COALESCE(SUM(equity_begin_bctcrl_ts224_amt), SUM(equity_begin_bctcrl_ts222_amt))) AS equity_begin_amt,
        MAX(submission_dt)                 AS submission_dt,
        MAX(submission_status_code)        AS submission_status_code,
        MAX(src_stm_code)                  AS src_stm_code,
        row_number() over (
            partition by sc_code, rpt_year, rpt_period, rpt_code,period_nbr
            order by MAX(CAST(sc_rpt_input_submission_code AS bigint)) desc
        ) as rn
    FROM joined
    GROUP BY sc_code, sc_nm, rpt_year, rpt_period, rpt_code, period_nbr, preferred_report_ind
)

SELECT
    CAST({{ generate_surrogate_key_bigint('OPR_SC_FIN_RPT_HIST', "concat_ws('-', agg.sc_code, agg.rpt_year, agg.period_nbr, agg.rpt_period, agg.rpt_code)") }} AS string) AS fin_rpt_hist_id,
    CAST(sc_code AS string)                  AS sc_code,
    CAST(sc_nm AS string)                    AS sc_nm,
    CAST(rpt_year AS int)                    AS rpt_year,
    CAST(rpt_period AS string)               AS rpt_period,
    CAST(rpt_code AS string)                 AS rpt_code,
    CAST(period_nbr AS int)                  AS period_nbr,
    CAST(revenue_amt AS decimal(23,2))       AS revenue_amt,
    CAST(profit_after_tax_amt AS decimal(23,2)) AS profit_after_tax_amt,
    CAST(ROUND(profit_after_tax_amt * 1000000000 / NULLIF((asset_end_amt + COALESCE(asset_begin_amt, asset_end_amt)) / 2, 0) * 100, 2) AS decimal(5,2)) AS roa_rate,
    CAST(ROUND(profit_after_tax_amt * 1000000000 / NULLIF((equity_end_amt + COALESCE(equity_begin_amt, equity_end_amt)) / 2, 0) * 100, 2) AS decimal(5,2)) AS roe_rate,
    CAST(submission_dt AS date)              AS submission_dt,
    CAST(submission_status_code AS string)   AS submission_status_code,
    CAST(preferred_report_ind AS string)     AS preferred_report_ind,
    CAST(src_stm_code AS string)             AS src_stm_code
FROM agg
WHERE rn = 1
