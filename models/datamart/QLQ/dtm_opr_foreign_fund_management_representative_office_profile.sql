/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_foreign_fund_management_representative_office_profile
* Program name: Dtm Opr Foreign Fund Management Representative Office Profile
* Created by: 
* Created date: 2026-11-09
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-09		claude (sync)		Tạo mới theo LLD commit 48c65dde (O_QLQ_83): hồ sơ VPĐD của tổ chức quản lý quỹ nước ngoài.
*                                       Lọc dòng: ou_tp_code = '0' (BRANCH_FLAG = 0) và MIN(ngày cấp giấy phép ESTABLISHMENT_OPERATION_LICENSE) <= etl_date (Active-only)
*--------------------------------------------------------------------*
*/

WITH establishment_license AS (
    SELECT
        ip_id,
        identification_issue_dt
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FOR_BRCH'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
        AND identification_issue_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd') 
),

license_info AS (
    SELECT
        ip_id,
        identification_nbr,
        identification_issue_dt
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FOR_BRCH'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
),

tax_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FOR_BRCH'
        AND identification_tp_code = 'TAX_ID'
),

foreign_branch_address AS (
    SELECT
        ip_id,
        adr_val
    FROM {{ ref('atm_ip_postal_address') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FOR_BRCH'
        AND adr_tp_code = 'FOREIGN_BRANCH'
),

cl_fms_status AS (
    SELECT
        cl_fms_status_code,
        cl_fms_status_nm
    FROM {{ ref('atm_cl_fms_status') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_STATUS'
),

foreign_fm_ou AS (
    SELECT
        foreign_fund_management_organization_unit_id,
        foreign_fund_management_organization_unit_code,
        foreign_fund_management_organization_unit_full_nm,
        operation_status_code,
        src_stm_code
    FROM {{ ref('dtm_foreign_fund_management_organization_unit_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FOR_BRCH'
        AND branch_tp_code = '0'
)

SELECT
    CAST(f.foreign_fund_management_organization_unit_code AS string)      AS foreign_fund_management_organization_unit_code,
    CAST(f.foreign_fund_management_organization_unit_full_nm AS string)   AS foreign_fund_management_organization_unit_full_nm,
    CAST(st.cl_fms_status_nm AS string)                                   AS operation_status_nm,
    CAST(license_info.identification_nbr AS string)                       AS license_nbr,
    CAST(license_info.identification_issue_dt AS date)                    AS license_dt,
    CAST(addr.adr_val AS string)                                          AS address,
    CAST(tax_id.identification_nbr AS string)                             AS tax_id_nbr,
    CAST(f.src_stm_code AS string)                                        AS src_stm_code
FROM foreign_fm_ou f
INNER JOIN establishment_license lic
    ON lic.ip_id = f.foreign_fund_management_organization_unit_id
LEFT JOIN license_info
    ON license_info.ip_id = f.foreign_fund_management_organization_unit_id
LEFT JOIN tax_id
    ON tax_id.ip_id = f.foreign_fund_management_organization_unit_id
LEFT JOIN foreign_branch_address addr
    ON addr.ip_id = f.foreign_fund_management_organization_unit_id
LEFT JOIN cl_fms_status st
    ON st.cl_fms_status_code = f.operation_status_code
