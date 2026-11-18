/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_fund_management_company_snpst
* Program name: Dtm Fct Fund Management Company Snpst
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description                             custodian_bank_count: decision_issue_dt NULL tính là 1900-01-01 (kết quả không đổi, viết lại theo LLD)
* 2026-10-27		claude (refactor)	Tách các CTE nguồn độc lập trước khi JOIN theo chuẩn CTE
* 2026-10-27		claude (sync)		Đồng bộ LLD commit 2200debe (O_QLQ_53): grain 1 dòng/tháng (ngày cuối tháng), nạp ĐỦ mọi tháng từ 2000-01
*                                       đến tháng của etl_date (CTE snpst_month); mọi cận last_day(...) <= ngày cuối tháng snapshot (cdr_dt_dim.cdr_dt)
* 2026-10-27		claude				Ghi chú rủi ro thiết kế (xem mục bên dưới), chưa đổi logic
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
*   R2. Thiếu partition nguồn (job dim fail, hstr ngày etl_date chưa có) => ghi đè bằng số 0, KHÔNG rơi nhánh DELETE.
*       Model dùng snpst_month làm bảng dẫn + LEFT JOIN + COALESCE(...,0): row_count luôn > 0, và chỉ cần thiếu MỘT nguồn
*       (Dim FMC, Dim chi nhánh NN, custodian bank, investment_fund/license) thì chỉ số tương ứng = 0 ở MỌI tháng và ghi đè
*       XOÁ SẠCH lịch sử đúng. RỦI RO LỚN NHẤT. Hướng xử lý: guard EXISTS cho từng nguồn, nguồn thiếu thì không ra dòng nào
*       (hoặc tách mỗi nhóm chỉ số thành 1 fact để lỗi 1 nguồn không kéo theo các chỉ số khác).
*   R3. Tháng hiện tại dùng last_day(etl_date) nên đếm cả bản ghi có ngày hiệu lực/cấp phép SAU etl_date trong cùng tháng
*       (vd start 2026-10-25, chạy 2026-10-15 vẫn đếm). GSDC dùng LEAST(cuối kỳ, etl_date). Cần chốt theo LLD O_QLQ_53.
*   R4. Trạng thái as-of không có lịch sử: operation_status_nm ('hoạt động', 'chờ đóng cửa', 'đóng cửa'...) lấy theo trạng thái
*       HIỆN TẠI nhưng áp cho mọi tháng quá khứ => công ty/VPĐD đã đóng cửa sau này bị loại khỏi (active) hoặc bị tính là
*       "closed" ở cả các tháng trước khi đóng. Nguồn Oracle không lưu lịch sử chuyển trạng thái; đúng as-of phải suy từ
*       ngày (effective_end_dt/suspension_dt so với ngày cuối tháng). Cần BA/LLD xác nhận.
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

establishment_license AS (
    SELECT
        ip_id,
        MIN(identification_issue_dt) AS identification_issue_dt
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
    GROUP BY 1
),

investment_fund AS (
    SELECT
        investment_fund_id
    FROM {{ ref('dtm_investment_fund_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

fund_management_company_dim AS (
    SELECT
        fmc_id,
        operation_status_code,
        actual_operation_commencement_dt                                                      AS operation_commencement_dt,
        suspension_dt,
        effective_end_dt
    FROM {{ ref('dtm_fund_management_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SECURITIES'
),

foreign_fm_ou_dim AS (
    SELECT
        foreign_fund_management_organization_unit_id                                          AS foreign_fm_ou_id,
        branch_tp_code,
        operation_status_code,
        effective_start_dt
    FROM {{ ref('dtm_foreign_fund_management_organization_unit_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FOR_BRCH'
),

custodian_bank AS (
    SELECT
        custodian_bank_id,
        decision_issue_dt
    FROM {{ ref('dtm_custodian_bank_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_BANK_MONI'
),

fund_management_company AS (
    SELECT
        fund_management_company_dim.fmc_id,
        LOWER(cl_fms_status.cl_fms_status_nm)                                                 AS operation_status_nm_lower,
        fund_management_company_dim.operation_commencement_dt,
        fund_management_company_dim.suspension_dt,
        fund_management_company_dim.effective_end_dt
    FROM fund_management_company_dim
    LEFT JOIN cl_fms_status
        ON cl_fms_status.cl_fms_status_code = fund_management_company_dim.operation_status_code
),

foreign_fm_ou AS (
    SELECT
        foreign_fm_ou_dim.foreign_fm_ou_id,
        foreign_fm_ou_dim.branch_tp_code,
        LOWER(cl_fms_status.cl_fms_status_nm)                                                 AS operation_status_nm_lower,
        foreign_fm_ou_dim.effective_start_dt
    FROM foreign_fm_ou_dim
    LEFT JOIN cl_fms_status
        ON cl_fms_status.cl_fms_status_code = foreign_fm_ou_dim.operation_status_code
),

fund_agg AS (
    SELECT
        snpst_month.snpst_dt,
        COUNT(investment_fund.investment_fund_id)                                             AS investment_fund_count
    FROM snpst_month
    CROSS JOIN investment_fund
    WHERE EXISTS (
        SELECT 1
        FROM establishment_license
        WHERE establishment_license.ip_id = investment_fund.investment_fund_id
            AND last_day(establishment_license.identification_issue_dt) <= snpst_month.snpst_dt
    )
    GROUP BY snpst_month.snpst_dt
),

fmc_agg AS (
    SELECT
        snpst_month.snpst_dt,
        COUNT(CASE WHEN fund_management_company.operation_status_nm_lower = 'hoạt động'
                    AND last_day(fund_management_company.operation_commencement_dt)
                        <= snpst_month.snpst_dt
                    AND (fund_management_company.suspension_dt IS NULL
                         OR fund_management_company.effective_end_dt IS NULL)
                   THEN fund_management_company.fmc_id END)                                   AS active_fund_management_company_count
    FROM snpst_month
    CROSS JOIN fund_management_company
    GROUP BY snpst_month.snpst_dt
),

foreign_fm_ou_agg AS (
    SELECT
        snpst_month.snpst_dt,
        COUNT(foreign_fm_ou.foreign_fm_ou_id)                                                 AS foreign_fund_management_organization_unit_count,
        COUNT(CASE WHEN foreign_fm_ou.operation_status_nm_lower = 'hoạt động'
                   THEN foreign_fm_ou.foreign_fm_ou_id END)                                   AS active_foreign_fund_management_organization_unit_count,
        COUNT(CASE WHEN foreign_fm_ou.operation_status_nm_lower LIKE '%chờ đóng cửa%'
                   THEN foreign_fm_ou.foreign_fm_ou_id END)                                   AS pending_closure_foreign_fund_management_organization_unit_count,
        COUNT(CASE WHEN foreign_fm_ou.operation_status_nm_lower NOT LIKE '%chờ%'
                    AND (foreign_fm_ou.operation_status_nm_lower LIKE '%đóng cửa%'
                         OR foreign_fm_ou.operation_status_nm_lower LIKE '%chấm dứt%'
                         OR foreign_fm_ou.operation_status_nm_lower LIKE '%giải thể%')
                   THEN foreign_fm_ou.foreign_fm_ou_id END)                                   AS closed_foreign_fund_management_organization_unit_count
    FROM snpst_month
    CROSS JOIN foreign_fm_ou
    WHERE foreign_fm_ou.branch_tp_code = '0'
        AND last_day(foreign_fm_ou.effective_start_dt) <= snpst_month.snpst_dt
    GROUP BY snpst_month.snpst_dt
),

custodian_bank_agg AS (
    SELECT
        snpst_month.snpst_dt,
        COUNT(CASE WHEN last_day(COALESCE(custodian_bank.decision_issue_dt, to_date('1900-01-01')))
                        <= snpst_month.snpst_dt
                   THEN custodian_bank.custodian_bank_id END)                                 AS custodian_bank_count
    FROM snpst_month
    CROSS JOIN custodian_bank
    GROUP BY snpst_month.snpst_dt
)

SELECT
    date_format(snpst_month.snpst_dt, 'yyyyMMdd')                                                  AS snpst_dt_dim_id,
    CAST(COALESCE(fund_agg.investment_fund_count, 0) AS int)                                                    AS investment_fund_count,
    CAST(COALESCE(fmc_agg.active_fund_management_company_count, 0) AS int)                                      AS active_fund_management_company_count,
    CAST(COALESCE(foreign_fm_ou_agg.foreign_fund_management_organization_unit_count, 0) AS int)                 AS foreign_fund_management_organization_unit_count,
    CAST(COALESCE(foreign_fm_ou_agg.active_foreign_fund_management_organization_unit_count, 0) AS int)          AS active_foreign_fund_management_organization_unit_count,
    CAST(COALESCE(foreign_fm_ou_agg.pending_closure_foreign_fund_management_organization_unit_count, 0) AS int) AS pending_closure_foreign_fund_management_organization_unit_count,
    CAST(COALESCE(foreign_fm_ou_agg.closed_foreign_fund_management_organization_unit_count, 0) AS int)          AS closed_foreign_fund_management_organization_unit_count,
    CAST(COALESCE(custodian_bank_agg.custodian_bank_count, 0) AS int)                                           AS custodian_bank_count
FROM snpst_month
LEFT JOIN fund_agg
    ON fund_agg.snpst_dt = snpst_month.snpst_dt
LEFT JOIN fmc_agg
    ON fmc_agg.snpst_dt = snpst_month.snpst_dt
LEFT JOIN foreign_fm_ou_agg
    ON foreign_fm_ou_agg.snpst_dt = snpst_month.snpst_dt
LEFT JOIN custodian_bank_agg
    ON custodian_bank_agg.snpst_dt = snpst_month.snpst_dt
