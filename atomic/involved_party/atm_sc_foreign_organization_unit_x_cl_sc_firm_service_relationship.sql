/*
*--------------------------------------------------------------------*
* Program code: atm_sc_foreign_organization_unit_x_cl_sc_firm_service_relationship
* Program name: Atomic Securities Company Foreign Organization Unit X Classification Securities Company Firm Service Relationship
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_LNK_SC_FIRM_FOREIGN_BRANCH_SERVICE.yaml (5 cot, Relative/scd2, PK (sc_foreign_ou_id, cl_sc_firm_service_id)); khoi phuc tu git 77a9749^; hash khop atm_sc_foreign_organization_unit_scms_sc_firm_foreign_branch va atm_cl_securities_company_firm_service (SCMS_CAT_SERVICE_LEGAL_CAPITAL)
* 2026-11-13		claude		[MOI] Khu trung theo cap (sc_firm_foreign_branch_id, service_id) bang ROW_NUMBER (id lon nhat); ODS lnk khong loc record_status nen co the lap
*--------------------------------------------------------------------*
*/

WITH ln_fo_br_se AS (
    SELECT
        sc_firm_foreign_branch_id
        , service_id
        , ROW_NUMBER() OVER (PARTITION BY sc_firm_foreign_branch_id, service_id ORDER BY id DESC) AS rn
    FROM {{ ref('ods_scms_lnk_sc_firm_foreign_branch_service') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH', "ln_fo_br_se.sc_firm_foreign_branch_id") }} AS sc_foreign_ou_id
    , CAST(ln_fo_br_se.sc_firm_foreign_branch_id AS string)                                                     AS sc_foreign_ou_code
    , {{ generate_surrogate_key_bigint('SCMS_CAT_SERVICE_LEGAL_CAPITAL', "ln_fo_br_se.service_id") }}           AS cl_sc_firm_service_id
    , CAST(ln_fo_br_se.service_id AS string)                                                                    AS cl_sc_firm_service_code
    , CAST('SCMS_LNK_SC_FIRM_FOREIGN_BRANCH_SERVICE' AS string)                                                 AS src_stm_code
FROM ln_fo_br_se
WHERE ln_fo_br_se.rn = 1