/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_fund_distribution_agent_snpst
* Program name: Dtm Fct Fund Distribution Agent Snpst
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-27		claude (sync)		Đồng bộ LLD commit 2200debe (O_QLQ_53): grain 1 dòng/tháng (ngày cuối tháng), nạp ĐỦ mọi tháng từ 2000-01
*                                       đến tháng của etl_date (CTE snpst_month); cận giấy phép identification_issue_dt <= ngày cuối tháng snapshot
* 2026-10-27		claude				Ghi chú rủi ro thiết kế (xem mục bên dưới), chưa đổi logic
* 2026-10-29		claude (sync)		Đồng bộ LLD commit 2de09a25 (O_QLQ_46(1)): bỏ điều kiện termination_dt IS NULL — đếm mọi ĐLPP có GCN
*                                       cấp <= cuối tháng, KHÔNG lọc trạng thái chấm dứt (đúng SQL BA). Rủi ro R4 bên dưới không còn áp dụng
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
*   R2. Thiếu partition nguồn (job dim fail, hstr ngày etl_date chưa có) => ghi đè bằng số sai. Model này CROSS JOIN từ Dim
*       đại lý: Dim rỗng => 0 dòng => macro rơi nhánh DELETE WHERE to_date(snpst_dt_dim_id,'yyyy-MM-dd') = etl_date
*       (id yyyyMMdd => to_date NULL => không xoá gì; cần xác nhận Spark không bật ANSI mode, nếu bật thì DELETE lỗi,
*       task fail nhưng vẫn không mất dữ liệu). NHƯNG nếu chỉ thiếu operation_license (Dim có) thì LEFT JOIN cho has_license = 0
*       => distribution_agent_count = 0 mọi tháng, ghi đè XOÁ SẠCH lịch sử đúng. Hướng xử lý: guard EXISTS cho từng nguồn.
*   R3. Tháng hiện tại dùng last_day(etl_date) nên đếm cả bản ghi có ngày cấp phép SAU etl_date trong cùng tháng
*       (vd cấp 2026-10-25, chạy 2026-10-15 vẫn đếm). GSDC dùng LEAST(cuối kỳ, etl_date). Cần chốt theo LLD O_QLQ_53.
*   R4. [ĐÃ ĐÓNG 2026-10-29, O_QLQ_46] LLD bỏ lọc termination_dt IS NULL — không còn lệch as-of theo trạng thái chấm dứt.
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

securities_distribution_agent AS (
    SELECT
        securities_distribution_agent_id
    FROM {{ ref('dtm_securities_distribution_agent_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_DISTRIBUTOR_AGENT'
),

operation_license AS (
    SELECT
        ip_id,
        MIN(identification_issue_dt) AS identification_issue_dt
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_DISTRIBUTOR_AGENT'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
    GROUP BY 1
),

agent_month AS (
    SELECT
        snpst_month.snpst_dt,
        securities_distribution_agent.securities_distribution_agent_id,
        MAX(CASE WHEN operation_license.identification_issue_dt <= snpst_month.snpst_dt
                 THEN 1 ELSE 0 END)                                                             AS has_license
    FROM snpst_month
    CROSS JOIN securities_distribution_agent
    LEFT JOIN operation_license
        ON operation_license.ip_id = securities_distribution_agent.securities_distribution_agent_id
    GROUP BY snpst_month.snpst_dt,
             securities_distribution_agent.securities_distribution_agent_id
)

SELECT
    date_format(agent_month.snpst_dt, 'yyyyMMdd')                                               AS snpst_dt_dim_id,
    CAST(COUNT(CASE WHEN agent_month.has_license = 1
                    THEN agent_month.securities_distribution_agent_id END) AS int)              AS distribution_agent_count
FROM agent_month
GROUP BY agent_month.snpst_dt
