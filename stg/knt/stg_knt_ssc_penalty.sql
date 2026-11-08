/*
*--------------------------------------------------------------------*
* Program code: stg_knt_ssc_penalty
* Program name: Staging KNT.SSC_PENALTY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                            AS id
    , CAST(decision_number AS string)            AS decision_number
    , CAST(decision_date AS date)                AS decision_date
    , CAST(name AS string)                       AS name
    , CAST(address AS string)                    AS address
    , CAST(activity_sector AS string)            AS activity_sector
    , CAST(tax_code AS string)                   AS tax_code
    , CAST(legal_representative_name AS string)  AS legal_representative_name
    , CAST(violation_act_desc AS string)         AS violation_act_desc
    , CAST(fine_amount AS int)                   AS fine_amount
    , CAST(supplementary_penalty_form AS string) AS supplementary_penalty_form
    , CAST(remedial_measure AS string)           AS remedial_measure
    , CAST(msg_packet_id AS int)                 AS msg_packet_id
    , CAST(issue_date AS date)                   AS issue_date
    , CAST(issue_place AS string)                AS issue_place
FROM {{ source('source_knt', 'raw_ssc_penalty') }}