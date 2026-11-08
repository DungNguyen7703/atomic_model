/*
*--------------------------------------------------------------------*
- Program code: dtm_fct_foreign_fund_management_organization_unit_snpst
- Program name: Dtm Fct Foreign Fund Management Organization Unit Snpst
- Created by: 
- Created date: 2026-09-28
*--------------------------------------------------------------------*
- Modified management
- Date          User                Description
- 2026-10-27    claude (sync)       Đồng bộ LLD commit 2200debe (O_QLQ_53): grain 1 dòng/tháng (ngày cuối tháng), nạp ĐỦ mọi tháng từ 2000-01
-                                   đến tháng của etl_date (CTE snpst_month); mốc so sánh :etl_date -> ngày cuối tháng snapshot
- 2026-10-27    optimized           Tối ưu hóa: gom MIN GP, gộp CTE, lọc sớm branch_tp_code = '1', thêm hint BROADCAST
- 2026-10-27    claude              Ghi chú rủi ro thiết kế (xem mục bên dưới), chưa đổi logic
*--------------------------------------------------------------------*
- CƠ CHẾ GHI (incremental_strategy: append, partition_by: snpst_dt_dim_id)
-   Mỗi lần chạy sinh mọi tháng 2000-01 -> tháng của etl_date, snpst_dt_dim_id = ngày cuối tháng (KHÔNG phải etl_date).
-   Macro: SET partitionOverwriteMode=dynamic + INSERT OVERWRITE => ghi đè TOÀN BỘ ~320 partition tháng mỗi run,
-   không nhân đôi, run sau thay run trước. Bảng chỉ giữ kết quả của lần chạy gần nhất, không lưu số liệu theo từng etl_date.
-   Không có cột ds_snpst_dt nên không biết partition do run ngày nào tạo ra.
-
- RỦI RO THIẾT KẾ (để tối ưu sau)
-   R1. Rerun etl_date cũ làm LÙI dữ liệu: rerun 2026-09-20 sau khi đã chạy 2026-10-15 ghi đè mọi tháng <= 2026-09 bằng
-       góc nhìn hstr ngày 20/09 (mất bản ghi nạp muộn 20/09 -> 15/10), partition tháng sau không bị chạm => bảng lẫn lộn.
-       orchestrator_daily không ảnh hưởng; orchestrator_backdate chạy ngày tăng dần nên run cuối (ngày mới nhất) thắng.
-   R2. Thiếu partition nguồn (job dim fail, hstr ngày etl_date chưa có) => foreign_fm_ou rỗng, LEFT JOIN vẫn trả mọi tháng
-       với branch_count = 0, row_count > 0 nên macro vẫn ghi đè => XOÁ SẠCH lịch sử đúng. RỦI RO LỚN NHẤT.
-       Hướng xử lý: thêm WHERE EXISTS (hstr etl_date, src FMS_FOR_BRCH) vào snpst_month -> kết quả rỗng thì macro rơi nhánh
-       DELETE WHERE to_date(snpst_dt_dim_id,'yyyy-MM-dd') = etl_date (id yyyyMMdd => to_date NULL => không xoá gì;
-       cần xác nhận Spark không bật ANSI mode, nếu bật thì DELETE lỗi, task fail nhưng vẫn không mất dữ liệu).
-   R3. Tháng hiện tại dùng last_day(etl_date) nên đếm cả bản ghi có effective_start_dt SAU etl_date trong cùng tháng
-       (vd start 2026-10-25, chạy 2026-10-15 vẫn đếm). GSDC dùng LEAST(cuối kỳ, etl_date). Cần chốt theo LLD O_QLQ_53.
-   R4. Trạng thái as-of không có lịch sử: nguồn Oracle chỉ lưu trạng thái mới nhất, kỳ quá khứ suy từ effective_start_dt /
-       effective_end_dt (đã dùng ở LEFT JOIN cuối); chuyển trạng thái không kèm ngày sẽ không phản ánh đúng.
-   R5. Hiệu năng/metadata: mỗi run rewrite ~320 partition nhỏ, Iceberg snapshot/metadata phình dần => cần expire_snapshots
-       định kỳ; có thể giới hạn chỉ ghi đè các tháng >= tháng thấp nhất có thay đổi nếu cần tối ưu.
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

establishment_license AS (
    SELECT
        ip_id,
        MIN(identification_issue_dt) AS identification_issue_dt
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}')
      AND ds_rcrd_st = 'ACTIVE'
      AND src_stm_code = 'FMS_FOR_BRCH'
      AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
    GROUP BY 1
),

foreign_fm_ou AS (
    -- Gộp Dim và License, lọc sớm chi nhánh (branch_tp_code = '1')
    SELECT
        dim.foreign_fund_management_organization_unit_id              AS foreign_fm_ou_id,
        COALESCE(dim.effective_start_dt, lic.identification_issue_dt) AS effective_start_dt,
        dim.effective_end_dt
    FROM {{ ref('dtm_foreign_fund_management_organization_unit_dim') }}_hstr dim
    LEFT JOIN establishment_license lic
        ON lic.ip_id = dim.foreign_fund_management_organization_unit_id
    WHERE dim.ds_snpst_dt = to_date('{{ var("etl_date") }}')
      AND dim.ds_rcrd_st = 'ACTIVE'
      AND dim.src_stm_code = 'FMS_FOR_BRCH'
      AND dim.branch_tp_code = '1'
)

SELECT 
    date_format(m.snpst_dt, 'yyyyMMdd') AS snpst_dt_dim_id,
    CAST(COUNT(f.foreign_fm_ou_id) AS int) AS branch_count
FROM snpst_month m
LEFT JOIN foreign_fm_ou f
    ON f.effective_start_dt <= m.snpst_dt
    AND (f.effective_end_dt IS NULL OR f.effective_end_dt > m.snpst_dt)
GROUP BY m.snpst_dt
