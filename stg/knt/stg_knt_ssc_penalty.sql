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
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: kieu int sang bigint (2 cot); kieu int sang decimal(38,10) (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                         AS id
    , CAST(decision_number AS string)            AS decision_number
    , CAST(decision_date AS date)                AS decision_date
    , CAST(name AS string)                       AS name
    , CAST(address AS string)                    AS address
    , CAST(activity_sector AS string)            AS activity_sector
    , CAST(tax_code AS string)                   AS tax_code
    , CAST(legal_representative_name AS string)  AS legal_representative_name
    , CAST(violation_act_desc AS string)         AS violation_act_desc
    , CAST(fine_amount AS decimal(38,10))        AS fine_amount
    , CAST(supplementary_penalty_form AS string) AS supplementary_penalty_form
    , CAST(remedial_measure AS string)           AS remedial_measure
    , CAST(msg_packet_id AS bigint)              AS msg_packet_id
    , CAST(issue_date AS date)                   AS issue_date
    , CAST(issue_place AS string)                AS issue_place
FROM {{ source('source_knt', 'raw_ssc_penalty') }}