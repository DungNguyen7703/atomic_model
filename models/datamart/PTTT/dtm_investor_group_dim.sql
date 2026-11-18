/*
*--------------------------------------------------------------------*
* Program code: dtm_investor_group_dim
* Program name: Dtm Investor Group Dim
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* GHI CHU:
* Day la dimension SEED TINH (static dimension), KHONG co nguon Atomic
* nao phia sau - 6 dong gia tri co dinh do nghiep vu PTTT dinh nghia
* (nhom NDT dung de phan tich dong tien giao dich). Vi khong co bang
* nguon dong (khong the ap dung scd2/scd4a de so sanh lich su thay doi),
* model duoc khai bao materialized: table trong schema yml (khong tim
* thay pattern seed/static dimension nao khac trong models/datamart/
* de tham chieu - vi du dtm_cl_dim doc tu bang atomic.uat_atm.cv that,
* khong phai seed tinh).
*--------------------------------------------------------------------*
*/

SELECT 
    CAST('FOREIGN' AS string) AS investor_group_code, 
    CAST('NĐT nước ngoài' AS string) AS investor_group_nm, 
    {{ generate_surrogate_key_bigint('PTTT_INVESTOR_GROUP', "'FOREIGN'") }} AS investor_group_dim_id, 
    CAST('PTTT_INVESTOR_GROUP' AS string) AS src_stm_code
UNION ALL
    SELECT CAST('PROPRIETARY' AS string) AS investor_group_code, 
    CAST('Tự doanh' AS string) AS investor_group_nm, 
    {{ generate_surrogate_key_bigint('PTTT_INVESTOR_GROUP', "'PROPRIETARY'") }} AS investor_group_dim_id, 
    CAST('PTTT_INVESTOR_GROUP' AS string) AS src_stm_code
UNION ALL
    SELECT CAST('DOMESTIC_INSTITUTION' AS string) AS investor_group_code, 
    CAST('Tổ chức trong nước' AS string) AS investor_group_nm, 
    {{ generate_surrogate_key_bigint('PTTT_INVESTOR_GROUP', "'DOMESTIC_INSTITUTION'") }} AS investor_group_dim_id, 
    CAST('PTTT_INVESTOR_GROUP' AS string) AS src_stm_code
UNION ALL
    SELECT CAST('DOMESTIC_INDIVIDUAL' AS string) AS investor_group_code, 
    CAST('Cá nhân trong nước' AS string) AS investor_group_nm, 
    {{ generate_surrogate_key_bigint('PTTT_INVESTOR_GROUP', "'DOMESTIC_INDIVIDUAL'") }} AS investor_group_dim_id, 
    CAST('PTTT_INVESTOR_GROUP' AS string) AS src_stm_code
UNION ALL
    SELECT CAST('FOREIGN_INDIVIDUAL' AS string) AS investor_group_code, 
    CAST('Cá nhân nước ngoài' AS string) AS investor_group_nm, 
    {{ generate_surrogate_key_bigint('PTTT_INVESTOR_GROUP', "'FOREIGN_INDIVIDUAL'") }} AS investor_group_dim_id, 
    CAST('PTTT_INVESTOR_GROUP' AS string) AS src_stm_code
UNION ALL
    SELECT CAST('FOREIGN_INSTITUTION' AS string) AS investor_group_code, 
    CAST('Tổ chức nước ngoài' AS string) AS investor_group_nm, 
    {{ generate_surrogate_key_bigint('PTTT_INVESTOR_GROUP', "'FOREIGN_INSTITUTION'") }} AS investor_group_dim_id, 
    CAST('PTTT_INVESTOR_GROUP' AS string) AS src_stm_code
