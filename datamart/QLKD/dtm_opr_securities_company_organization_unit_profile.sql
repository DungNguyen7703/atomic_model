/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_securities_company_organization_unit_profile
* Program name: Dtm Opr Securities Company Organization Unit Profile
* Created by: tuan.nguyenvanb
* Created date: 2026-10-02
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-02		tuan.nguyenvanb		[SUA] Bo sung cot business_line_nm_list
*                                       theo dung LLD: BRANCH dung LATERAL
*                                       VIEW EXPLODE(business_lines) + JOIN
*                                       cl_securities_company_firm_service
*                                       filter catalog_code IN ('MG','BLPH',
*                                       'TVDT','TD'); TRANSACTION_OFFICE dung
*                                       atm_sc_ou_x_cl_sc_firm_service_
*                                       relationship filter catalog_code IN
*                                       ('MG','TVDT'); REP_OFFICE luon NULL.
* 2026-10-27		claude				[SUA theo doi chieu Mapping LLD + xac
*                                       nhan nguoi dung] decision_dt: doi tu
*                                       lay truc tiep sc_or_un.decision_dt
*                                       sang LEFT JOIN atm_ip_alternative_
*                                       identification (identification_tp_
*                                       code = 'ESTABLISHMENT_OPERATION_
*                                       LICENSE') lay identification_issue_dt,
*                                       dung 3 Mapping CSV. director_nm nhanh
*                                       BRANCH: doi sang COALESCE(director_nm,
*                                       representative_nm) theo dung mo ta
*                                       Mapping (uu tien Director Name, fallback
*                                       Representative Name).
* 2026-10-27		claude				[SUA theo doi chieu Mapping LLD] JOIN
*                                       ip_postal_address: doi tu JOIN (INNER)
*                                       sang LEFT JOIN o ca 3 nhanh UNION -
*                                       Mapping mo ta ro LEFT JOIN, don vi
*                                       khong co dia chi van phai giu dong
*                                       (adr_val = NULL) thay vi bi loai bo.
*--------------------------------------------------------------------*
*/

WITH sc_or_un AS (
    SELECT
        sc_ou_id,
        sc_ou_code,
        sc_code,
        ou_tp_code,
        ou_nm,
        director_nm,
        cl_sc_firm_status_code,
        src_stm_code,
        representative_nm,
        business_lines
    FROM {{ ref('atm_sc_organization_unit') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),
ip_po_adr AS (
    SELECT
        ip_id,
        adr_tp_code,
        adr_val,
        src_stm_code
    FROM {{ ref('atm_ip_postal_address') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
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
cl_sc_fi_se AS (
    SELECT
        cl_sc_firm_service_id,
        cl_sc_firm_service_code,
        cl_sc_firm_service_nm,
        catalog_code,
        src_stm_code
    FROM {{ ref('atm_cl_securities_company_firm_service') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_CAT_SERVICE_LEGAL_CAPITAL'
),
ou_x_cl_sc_fi_se AS (
    SELECT
        sc_ou_code,
        cl_sc_firm_service_id
    FROM {{ ref('atm_sc_ou_x_cl_sc_firm_service_relationship') }}
    WHERE src_stm_code = 'SCMS_LNK_TRANSACTION_OFFICE_SERVICE'
),
branch_service_lines AS (
    SELECT
        sc_or_un.sc_ou_code,
        TRIM(bl.service_id_txt) AS service_id_txt
    FROM sc_or_un
    LATERAL VIEW EXPLODE(
        SPLIT(sc_or_un.business_lines, ',')
    ) bl AS service_id_txt
    WHERE sc_or_un.src_stm_code = 'SCMS_SC_FIRM_BRANCH'
),
bl_branch AS (
    SELECT
        branch_service_lines.sc_ou_code,
        ARRAY_JOIN(
            SORT_ARRAY(
                COLLECT_LIST(cl_sc_fi_se.cl_sc_firm_service_nm)
            ),
            ', '
        ) AS business_line_nm_list
    FROM branch_service_lines
    LEFT JOIN cl_sc_fi_se
        ON cl_sc_fi_se.cl_sc_firm_service_code =
           branch_service_lines.service_id_txt
        AND cl_sc_fi_se.catalog_code IN ('MG', 'BLPH', 'TVDT', 'TD')
    GROUP BY branch_service_lines.sc_ou_code
),
bl_transaction_office AS (
    SELECT
        sc_or_un.sc_ou_code,
        ARRAY_JOIN(
            SORT_ARRAY(
                COLLECT_LIST(cl_sc_fi_se.cl_sc_firm_service_nm)
            ),
            ', '
        ) AS business_line_nm_list
    FROM sc_or_un
    LEFT JOIN ou_x_cl_sc_fi_se
        ON ou_x_cl_sc_fi_se.sc_ou_code = sc_or_un.sc_ou_code
    LEFT JOIN cl_sc_fi_se
        ON cl_sc_fi_se.cl_sc_firm_service_id =
           ou_x_cl_sc_fi_se.cl_sc_firm_service_id
        AND cl_sc_fi_se.catalog_code IN ('MG', 'TVDT')
    WHERE sc_or_un.src_stm_code =
          'SCMS_SC_FIRM_TRANSACTION_OFFICE'
    GROUP BY sc_or_un.sc_ou_code
)
SELECT
    CAST(sc_or_un.sc_ou_code AS string)          AS sc_ou_code,
    CAST(sc_or_un.sc_code AS string)             AS sc_code,
    CAST(sc_or_un.ou_tp_code AS string)          AS ou_tp_code,
    CAST(sc_or_un.ou_nm AS string)               AS ou_nm,
    CAST(ip_po_adr.adr_val AS string)            AS adr_val,
    CAST(ip_al_id_estb.identification_issue_dt AS date) AS decision_dt,
    CAST(sc_or_un.representative_nm AS string)   AS director_nm,
    CAST(sc_or_un.cl_sc_firm_status_code AS string) AS cl_firm_status_code,
    CAST(bl_tr_of.business_line_nm_list AS string) AS business_line_nm_list,
    CAST(sc_or_un.src_stm_code AS string)        AS src_stm_code
FROM sc_or_un
LEFT JOIN ip_po_adr ON sc_or_un.sc_ou_id = ip_po_adr.ip_id
    AND sc_or_un.src_stm_code = 'SCMS_SC_FIRM_TRANSACTION_OFFICE'
    AND ip_po_adr.adr_tp_code = 'TRANSACTION_OFFICE'
    AND ip_po_adr.src_stm_code = 'SCMS_SC_FIRM_TRANSACTION_OFFICE'
LEFT JOIN bl_transaction_office bl_tr_of
    ON  bl_tr_of.sc_ou_code = sc_or_un.sc_ou_code
LEFT JOIN ip_al_id_estb
    ON  ip_al_id_estb.ip_id = sc_or_un.sc_ou_id
    AND ip_al_id_estb.src_stm_code = 'SCMS_SC_FIRM_TRANSACTION_OFFICE'
WHERE sc_or_un.src_stm_code = 'SCMS_SC_FIRM_TRANSACTION_OFFICE'

UNION ALL

SELECT
    CAST(sc_or_un.sc_ou_code AS string)          AS sc_ou_code,
    CAST(sc_or_un.sc_code AS string)             AS sc_code,
    CAST(sc_or_un.ou_tp_code AS string)          AS ou_tp_code,
    CAST(sc_or_un.ou_nm AS string)               AS ou_nm,
    CAST(ip_po_adr.adr_val AS string)            AS adr_val,
    CAST(ip_al_id_estb.identification_issue_dt AS date) AS decision_dt,
    CAST(sc_or_un.representative_nm AS string)   AS director_nm,
    CAST(sc_or_un.cl_sc_firm_status_code AS string) AS cl_firm_status_code,
    CAST(NULL AS string)                         AS business_line_nm_list,
    CAST(sc_or_un.src_stm_code AS string)        AS src_stm_code
FROM sc_or_un
LEFT JOIN ip_po_adr ON sc_or_un.sc_ou_id = ip_po_adr.ip_id
    AND sc_or_un.src_stm_code = 'SCMS_SC_FIRM_REP_OFFICE'
    AND ip_po_adr.adr_tp_code = 'REP_OFFICE'
    AND ip_po_adr.src_stm_code = 'SCMS_SC_FIRM_REP_OFFICE'
LEFT JOIN ip_al_id_estb
    ON  ip_al_id_estb.ip_id = sc_or_un.sc_ou_id
    AND ip_al_id_estb.src_stm_code = 'SCMS_SC_FIRM_REP_OFFICE'
WHERE sc_or_un.src_stm_code = 'SCMS_SC_FIRM_REP_OFFICE'

UNION ALL

SELECT
    CAST(sc_or_un.sc_ou_code AS string)          AS sc_ou_code,
    CAST(sc_or_un.sc_code AS string)             AS sc_code,
    CAST(sc_or_un.ou_tp_code AS string)          AS ou_tp_code,
    CAST(sc_or_un.ou_nm AS string)               AS ou_nm,
    CAST(ip_po_adr.adr_val AS string)            AS adr_val,
    CAST(ip_al_id_estb.identification_issue_dt AS date) AS decision_dt,
    CAST(COALESCE(sc_or_un.director_nm, sc_or_un.representative_nm) AS string) AS director_nm,
    CAST(sc_or_un.cl_sc_firm_status_code AS string) AS cl_firm_status_code,
    CAST(bl_br.business_line_nm_list AS string)  AS business_line_nm_list,
    CAST(sc_or_un.src_stm_code AS string)        AS src_stm_code
FROM sc_or_un
LEFT JOIN ip_po_adr ON sc_or_un.sc_ou_id = ip_po_adr.ip_id
    AND sc_or_un.src_stm_code = 'SCMS_SC_FIRM_BRANCH'
    AND ip_po_adr.adr_tp_code = 'BRANCH'
    AND ip_po_adr.src_stm_code = 'SCMS_SC_FIRM_BRANCH'
LEFT JOIN bl_branch bl_br
    ON  bl_br.sc_ou_code = sc_or_un.sc_ou_code
LEFT JOIN ip_al_id_estb
    ON  ip_al_id_estb.ip_id = sc_or_un.sc_ou_id
    AND ip_al_id_estb.src_stm_code = 'SCMS_SC_FIRM_BRANCH'
WHERE sc_or_un.src_stm_code = 'SCMS_SC_FIRM_BRANCH'