/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_investment_fund_count_snpst
* Program name: Dtm Fct Investment Fund Count Snapshot
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-11		claude (sync)		Đồng bộ LLD commit f5a29074 (O_QLQ_85, SCHEMA-CHANGING): thêm active_fund_count / inactive_fund_count (int) —
*                                       đếm quỹ theo trạng thái Classification FMS Status (LOWER(cl_fms_status_nm) = / <> 'hoạt động'), cùng tập quỹ
*                                       và cận giấy phép với fund_count; quỹ chưa có trạng thái không được đếm (đúng SQL BA). Trạng thái lấy từ
*                                       dim.operation_status_code JOIN atm_cl_fms_status (cùng pattern dtm_fct_fund_management_company_snpst)
*--------------------------------------------------------------------*
* CƠ CHẾ GHI (incremental_strategy: append, partition_by: snpst_dt_dim_id)
*   Mỗi lần chạy sinh mọi tháng 2000-01 -> tháng của etl_date, snpst_dt_dim_id = ngày cuối tháng (KHÔNG phải etl_date).
*   Macro: SET partitionOverwriteMode=dynamic + INSERT OVERWRITE => ghi đè TOÀN BỘ ~320 partition tháng mỗi run,
*   không nhân đôi, run sau thay run trước. Bảng chỉ giữ kết quả của lần chạy gần nhất, không lưu số liệu theo từng etl_date.
*   Không có cột ds_snpst_dt nên không biết partition do run ngày nào tạo ra.
*
* RỦI RO THIẾT KẾ (để tối ưu sau; chung cho các fct_*_snpst grain tháng của QLQ)
*   R1. Rerun etl_date cũ làm LÙI dữ liệu: rerun 2026-09-20 sau khi đã chạy 2026-10-15 ghi đè mọi tháng <= 2026-09 bằng
*       góc nhìn hstr ngày 20/09 (mất bản ghi nạp muộn 20/09 -> 15/10), partition tháng sau không bị chạm => bảng lẫn lộn.
*       orchestrator_daily không ảnh hưởng; orchestrator_backdate chạy ngày tăng dần nên run cuối (ngày mới nhất) thắng.
*   R2. Thiếu partition nguồn (job dim fail, hstr ngày etl_date chưa có). Model này CROSS JOIN + EXISTS: thiếu investment_fund
*       hoặc establishment_license => 0 dòng => macro rơi nhánh DELETE WHERE to_date(snpst_dt_dim_id,'yyyy-MM-dd') = etl_date
*       (id yyyyMMdd => to_date NULL => không xoá gì; cần xác nhận Spark không bật ANSI mode, nếu bật thì DELETE lỗi,
*       task fail nhưng vẫn không mất dữ liệu) => tương đối an toàn. Riêng thiếu fund_type_dim (LEFT JOIN cuối) thì
*       fund_type_id = NULL cho mọi dòng và vẫn ghi đè lịch sử. Hướng xử lý: guard EXISTS cho fund_tp.
*   R3. Tháng hiện tại dùng last_day(etl_date) nên đếm cả quỹ có ngày cấp phép SAU etl_date trong cùng tháng
*       (vd cấp 2026-10-25, chạy 2026-10-15 vẫn đếm). GSDC dùng LEAST(cuối kỳ, etl_date). Cần chốt theo LLD O_QLQ_53.
*   R4. Loại hình quỹ (fund_tp_code) và sự tồn tại của quỹ lấy theo trạng thái HIỆN TẠI của Dim: quỹ đổi loại hình sau này
*       bị tính vào loại hình mới ở mọi tháng quá khứ; nguồn Oracle không có lịch sử đổi loại hình.
*   R5. Hiệu năng/metadata: mỗi run rewrite ~320 partition nhỏ, Iceberg snapshot/metadata phình dần => cần expire_snapshots
*       định kỳ; có thể giới hạn chỉ ghi đè các tháng >= tháng thấp nhất có thay đổi nếu cần tối ưu.
*--------------------------------------------------------------------*
*/

WITH snpst_month AS (
    -- Sinh trực tiếp mảng ngày cuối tháng từ năm 2000 đến tháng của etl_date trong 1 toán tử
    SELECT explode(
        transform(
            sequence(
                DATE '2000-01-01', 
                trunc(to_date('{{ var("etl_date") }}'), 'MM'), 
                INTERVAL 1 MONTH
            ),
            d -> last_day(d)
        )
    ) AS snpst_dt
),

cl_fms_status AS (
    SELECT
        cl_fms_status_code,
        cl_fms_status_nm
    FROM {{ ref('atm_cl_fms_status') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_STATUS'
),

investment_fund AS (
    SELECT
        investment_fund_id,
        fund_tp_code,
        charter_capital_amt,
        operation_status_code,
        src_stm_code
    FROM {{ ref('dtm_investment_fund_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

establishment_license AS (
    SELECT
        ip_id,
        identification_issue_dt
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
),

fund_month AS (
    SELECT
        snpst_month.snpst_dt,
        investment_fund.investment_fund_id,
        investment_fund.fund_tp_code,
        investment_fund.charter_capital_amt,
        LOWER(cl_fms_status.cl_fms_status_nm) AS operation_status_nm_lower,
        investment_fund.src_stm_code
    FROM snpst_month
    CROSS JOIN investment_fund
    LEFT JOIN cl_fms_status
        ON cl_fms_status.cl_fms_status_code = investment_fund.operation_status_code
    WHERE EXISTS (
        SELECT 1
        FROM establishment_license
        WHERE establishment_license.ip_id = investment_fund.investment_fund_id
            AND last_day(establishment_license.identification_issue_dt) <= snpst_month.snpst_dt
    )
),

agg AS (
    SELECT
        snpst_dt,
        fund_tp_code,
        src_stm_code,
        COUNT(investment_fund_id)                                                               AS fund_count,
        SUM(charter_capital_amt)                                                                AS charter_capital_amt,
        COUNT(CASE WHEN operation_status_nm_lower = 'hoạt động' THEN investment_fund_id END)    AS active_fund_count,
        COUNT(CASE WHEN operation_status_nm_lower <> 'hoạt động' THEN investment_fund_id END)   AS inactive_fund_count
    FROM fund_month
    GROUP BY snpst_dt, fund_tp_code, src_stm_code
),

fund_tp AS (
    SELECT
        fund_type_id,
        fund_type_code
    FROM {{ ref('dtm_fund_type_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUND_TYPE'
)

SELECT
    date_format(agg.snpst_dt, 'yyyyMMdd')                                                       AS snpst_dt_dim_id
    , CAST(fund_tp.fund_type_id AS string)                                                      AS fund_type_id
    , CAST(agg.fund_count AS int)                                                               AS fund_count
    , CAST(agg.charter_capital_amt AS decimal(23,2))                                            AS charter_capital_amt
    , CAST(agg.active_fund_count AS int)                                                        AS active_fund_count
    , CAST(agg.inactive_fund_count AS int)                                                      AS inactive_fund_count
    , CAST(agg.src_stm_code AS string)                                                          AS src_stm_code
FROM agg
LEFT JOIN fund_tp
    ON fund_tp.fund_type_code = agg.fund_tp_code
