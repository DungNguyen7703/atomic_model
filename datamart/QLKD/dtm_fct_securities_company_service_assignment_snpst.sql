/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_company_service_assignment_snpst
* Program name: Dtm Fct Securities Company Service Assignment Snpst
* Created by: tuan.nguyenvanb
* Created date: 2026-09-17
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-17		tuan.nguyenvanb		[LLD QLKD v4.9, commit 8857a197] Sinh moi -
*                                       Fact Securities Company Service Assignment
*                                       Snapshot (Nhom 2/3/4). Grain: 1 CTCK x 1 dich
*                                       vu/nghiep vu x 1 ngay snapshot D (etl_date) -
*                                       full-scan toan bo assignment CON HIEU LUC tai
*                                       ngay D (Start Date <= D AND (End Date IS NULL
*                                       OR End Date > D)). LLD khong mo ta atomic nguon
*                                       (atm_sc_x_cl_sc_firm_service_relationship) la
*                                       scd4a/_hstr - doc thang bang atomic (current
*                                       state), tu loc hieu luc theo etl_date. CAN XAC
*                                       NHAN LAI khi dong nghiep build xong atomic, doi
*                                       sang _hstr + ds_snpst_dt neu atomic la scd4a.
*--------------------------------------------------------------------*
*/

-- Dedupe ROW_NUMBER (sc_code, cl_sc_firm_service_code) - phong ngua nguon co >1 giay phep
-- cung hieu luc cho cung 1 to hop CTCK x dich vu (vd gia han lien tiep, du lieu trung) -
-- LLD khong de cap truong hop nay nhung ap dung dung pattern da dung cho oss_val/
-- free_float_val cua GSTT, tranh MERGE_CARDINALITY_VIOLATION/fan-out o tang tren.
WITH sc_x_se AS (
    SELECT
        sc_code,
        cl_sc_firm_service_code,
        license_nbr,
        license_dt,
        start_dt,
        end_dt,
        src_stm_code
    FROM {{ ref('atm_sc_x_cl_sc_firm_service_relationship') }}
    WHERE src_stm_code = 'SCMS_LNK_SC_FIRM_SERVICE'
        AND ds_rcrd_st = 'ACTIVE'
        -- AND ds_rcrd_eff_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

cd_dt_di AS (
    SELECT cdr_dt_dim_id
    FROM {{ ref('dtm_cdr_dt_dim') }}
    WHERE cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

se_co_di AS (
    SELECT
        securities_company_dim_id,
        sc_code
    FROM {{ ref('dtm_securities_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

se_cl_di AS (
    SELECT
        securities_service_cl_dim_id,
        cl_sc_firm_service_code
    FROM {{ ref('dtm_securities_service_cl_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    CAST(cd_dt_di.cdr_dt_dim_id AS string)                     AS snpst_dt_dim_id,
    CAST(se_co_di.securities_company_dim_id AS string)         AS securities_company_dim_id,
    CAST(se_cl_di.securities_service_cl_dim_id AS string)      AS securities_service_cl_dim_id,
    CAST(sc_x_se.license_nbr AS string)                        AS license_nbr,
    CAST(sc_x_se.license_dt AS date)                           AS license_dt,
    CAST(sc_x_se.start_dt AS date)                             AS start_dt,
    CAST(sc_x_se.end_dt AS date)                               AS end_dt,
    CAST(sc_x_se.src_stm_code AS string)                       AS src_stm_code
FROM sc_x_se
CROSS JOIN cd_dt_di
LEFT JOIN se_co_di
    ON se_co_di.sc_code = sc_x_se.sc_code
LEFT JOIN se_cl_di
    ON se_cl_di.cl_sc_firm_service_code = sc_x_se.cl_sc_firm_service_code
