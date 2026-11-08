/*
*--------------------------------------------------------------------*
* Program code: stg_ids_dossier_appraisal_result
* Program name: Staging IDS.DOSSIER_APPRAISAL_RESULT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(securities_offering_id AS int)    AS securities_offering_id
    , CAST(company_tender_offer_id AS int)   AS company_tender_offer_id
    , CAST(company_treasury_share_id AS int) AS company_treasury_share_id
    , CAST(appraisal_criteria_id AS int)     AS appraisal_criteria_id
    , CAST(result_status_cd AS string)       AS result_status_cd
    , CAST(created_by AS string)             AS created_by
    , CAST(created_date AS date)             AS created_date
    , CAST(updated_by AS string)             AS updated_by
    , CAST(updated_date AS date)             AS updated_date
    , CAST(explanation AS string)            AS explanation
FROM {{ source('source_ids', 'raw_dossier_appraisal_result') }}