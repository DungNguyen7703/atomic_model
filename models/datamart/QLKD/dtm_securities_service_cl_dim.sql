/*
*--------------------------------------------------------------------*
* Program code: dtm_securities_service_cl_dim
* Program name: Dtm Securities Service Cl Dim
* Created by: tuan.nguyenvanb
* Created date: 2026-09-17
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-17		tuan.nguyenvanb		[LLD QLKD v4.9, commit 8857a197] Sinh moi -
*                                       Securities Service Classification Dimension
*                                       (Nhom 2/3/4), nguon atm_cl_securities_company_
*                                       firm_service (SCMS_CAT_SERVICE_LEGAL_CAPITAL).
*--------------------------------------------------------------------*
*/

WITH cl_se AS (
    SELECT
        cl_sc_firm_service_code,
        cl_sc_firm_service_nm,
        description,
        catalog_tp,
        catalog_code,
        application_tp_code,
        legal_capital_amt,
        src_stm_code
    FROM {{ ref('atm_cl_securities_company_firm_service') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_CAT_SERVICE_LEGAL_CAPITAL'
        -- AND ds_rcrd_isrt_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
)

SELECT
    CAST({{ generate_surrogate_key_bigint('SCMS_CAT_SERVICE_LEGAL_CAPITAL', "cl_sc_firm_service_code") }} AS string) AS securities_service_cl_dim_id,
    CAST(cl_sc_firm_service_code AS string)                              AS cl_sc_firm_service_code,
    CAST(cl_sc_firm_service_nm AS string)                                AS cl_sc_firm_service_nm,
    CAST(description AS string)                                          AS description,
    CAST(catalog_tp AS string)                                           AS catalog_tp,
    CAST(catalog_code AS string)                                         AS catalog_code,
    CAST(application_tp_code AS string)                                  AS application_tp_code,
    CAST(legal_capital_amt AS decimal(23,2))                             AS legal_capital_amt,
    CAST(src_stm_code AS string)                                         AS src_stm_code
FROM cl_se
