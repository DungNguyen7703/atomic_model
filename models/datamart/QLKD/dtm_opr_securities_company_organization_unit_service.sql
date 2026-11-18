/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_securities_company_organization_unit_service
* Program name: Dtm Opr Securities Company Organization Unit Service
* Created by: tuan.nguyenvanb
* Created date: 2026-10-02
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-02		tuan.nguyenvanb		[MOI] Sinh moi theo LLD QLKD -
*                                       Operational Securities Company
*                                       Organization Unit Service, gop 2
*                                       nguon: SCMS_LNK_TRANSACTION_OFFICE_
*                                       SERVICE (qua atm_sc_ou_x_cl_sc_firm_
*                                       service_relationship) va
*                                       SCMS_SC_FIRM_BRANCH (LATERAL VIEW
*                                       EXPLODE business_lines).
* 2026-10-27		claude				[SUA theo doi chieu Mapping LLD + xac
*                                       nhan nguoi dung] decision_dt: doi tu
*                                       lay truc tiep atm_sc_organization_unit.
*                                       decision_dt sang LEFT JOIN atm_ip_
*                                       alternative_identification
*                                       (identification_tp_code =
*                                       'ESTABLISHMENT_OPERATION_LICENSE') lay
*                                       identification_issue_dt, dung 2
*                                       Mapping CSV. Bo filter
*                                       record_status_code = '1' o ca 2 CTE
*                                       driving (atomic da bo cot nay theo
*                                       HLD O_QLKD_41, nguoi dung xac nhan).
* 2026-10-27		claude				[SUA theo doi chieu Mapping LLD] JOIN
*                                       cl_securities_company_firm_service:
*                                       doi tu LEFT JOIN sang JOIN (INNER) o
*                                       ca 2 nhanh UNION - Mapping mo ta ro
*                                       INNER JOIN, dong dich vu khong khop
*                                       danh muc (catalog_code) phai bi loai
*                                       thay vi giu lai.
* 2026-10-27		claude				[SUA theo yeu cau nguoi dung] Surrogate
*                                       key organization_unit_service_id (ca 2
*                                       nhanh UNION): doi cu phap noi chuoi
*                                       input tu CONCAT(a,'|',b,'|',c) sang
*                                       concat_ws('-', a, b, c) theo dung
*                                       template chung cua repo. Giu nguyen
*                                       namespace va tap cot BK.
*--------------------------------------------------------------------*
*/

WITH ou_x_cl_sc_fi_se AS (
    SELECT
        sc_ou_code,
        cl_sc_firm_service_id,
        cl_sc_firm_service_code,
        src_stm_code
    FROM {{ ref('atm_sc_ou_x_cl_sc_firm_service_relationship') }}
    WHERE src_stm_code = 'SCMS_LNK_TRANSACTION_OFFICE_SERVICE'
),

sc_or_un_tr_of AS (
    SELECT
        sc_ou_id,
        sc_ou_code,
        sc_code,
        ou_tp_code,
        src_stm_code
    FROM {{ ref('atm_sc_organization_unit') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_TRANSACTION_OFFICE'
),

sc_or_un_br AS (
    SELECT
        sc_ou_id,
        sc_ou_code,
        sc_code,
        ou_tp_code,
        business_lines,
        src_stm_code
    FROM {{ ref('atm_sc_organization_unit') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_BRANCH'
        AND business_lines IS NOT NULL
),

cl_sc_fi_se AS (
    SELECT
        cl_sc_firm_service_id,
        cl_sc_firm_service_code,
        catalog_code,
        src_stm_code
    FROM {{ ref('atm_cl_securities_company_firm_service') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_CAT_SERVICE_LEGAL_CAPITAL'
),

ip_al_id_estb AS (
    SELECT
        ip_id,
        identification_issue_dt,
        src_stm_code
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
),

-- Tách business_lines thành từng mã dịch vụ của BRANCH
branch_service_lines AS (
    SELECT
        sc_or_un_br.sc_ou_id,
        sc_or_un_br.sc_ou_code,
        sc_or_un_br.sc_code,
        sc_or_un_br.ou_tp_code,
        sc_or_un_br.src_stm_code,
        TRIM(bl.service_id_txt) AS service_id_txt
    FROM sc_or_un_br
    LATERAL VIEW EXPLODE(
        SPLIT(sc_or_un_br.business_lines, ',')
    ) bl AS service_id_txt
)

-- Nguồn 1: TRANSACTION_OFFICE
SELECT
    CAST(
        {{ generate_surrogate_key_bigint(
            'SCMS_LNK_TRANSACTION_OFFICE_SERVICE',
            "concat_ws('-', ou_x_cl_sc_fi_se.sc_ou_code, sc_or_un_tr_of.ou_tp_code, ou_x_cl_sc_fi_se.cl_sc_firm_service_code)"
        ) }}
        AS string
    ) AS organization_unit_service_id,
    CAST(ou_x_cl_sc_fi_se.sc_ou_code AS string)
        AS sc_ou_code,
    CAST(ou_x_cl_sc_fi_se.cl_sc_firm_service_code AS string)
        AS cl_sc_firm_service_code,
    CAST(sc_or_un_tr_of.sc_code AS string)
        AS sc_code,
    CAST(sc_or_un_tr_of.ou_tp_code AS string)
        AS ou_tp_code,
    CAST(cl_sc_fi_se.catalog_code AS string)
        AS catalog_code,
    CAST(ip_al_id_estb.identification_issue_dt AS date)
        AS decision_dt,
    CAST(ou_x_cl_sc_fi_se.src_stm_code AS string)
        AS src_stm_code
FROM ou_x_cl_sc_fi_se
JOIN sc_or_un_tr_of
    ON sc_or_un_tr_of.sc_ou_code =
       ou_x_cl_sc_fi_se.sc_ou_code
JOIN cl_sc_fi_se
    ON cl_sc_fi_se.cl_sc_firm_service_id =
       ou_x_cl_sc_fi_se.cl_sc_firm_service_id
LEFT JOIN ip_al_id_estb
    ON ip_al_id_estb.ip_id = sc_or_un_tr_of.sc_ou_id
    AND ip_al_id_estb.src_stm_code = 'SCMS_SC_FIRM_TRANSACTION_OFFICE'

UNION ALL

-- Nguồn 2: BRANCH
SELECT
    CAST(
        {{ generate_surrogate_key_bigint(
            'SCMS_SC_FIRM_BRANCH',
            "concat_ws('-', branch_service_lines.sc_ou_code, branch_service_lines.ou_tp_code, branch_service_lines.service_id_txt)"
        ) }}
        AS string
    ) AS organization_unit_service_id,
    CAST(branch_service_lines.sc_ou_code AS string)
        AS sc_ou_code,
    CAST(branch_service_lines.service_id_txt AS string)
        AS cl_sc_firm_service_code,
    CAST(branch_service_lines.sc_code AS string)
        AS sc_code,
    CAST(branch_service_lines.ou_tp_code AS string)
        AS ou_tp_code,
    CAST(cl_sc_fi_se.catalog_code AS string)
        AS catalog_code,
    CAST(ip_al_id_estb.identification_issue_dt AS date)
        AS decision_dt,
    CAST(branch_service_lines.src_stm_code AS string)
        AS src_stm_code
FROM branch_service_lines
JOIN cl_sc_fi_se
    ON cl_sc_fi_se.cl_sc_firm_service_code =
       branch_service_lines.service_id_txt
LEFT JOIN ip_al_id_estb
    ON ip_al_id_estb.ip_id = branch_service_lines.sc_ou_id
    AND ip_al_id_estb.src_stm_code = 'SCMS_SC_FIRM_BRANCH'