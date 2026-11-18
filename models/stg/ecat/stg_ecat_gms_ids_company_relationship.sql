/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_gms_ids_company_relationship
* Program name: Staging ECAT.GMS_IDS_COMPANY_RELATIONSHIP
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu decimal(38,10) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(company_profile_id AS string)         AS company_profile_id
    , CAST(company_profile_version_id AS string) AS company_profile_version_id
    , CAST(company_profile_stable_id AS string)  AS company_profile_stable_id
    , CAST(relationship_type_cd AS string)       AS relationship_type_cd
    , CAST(full_name_vi AS string)               AS full_name_vi
    , CAST(full_name_en AS string)               AS full_name_en
    , CAST(business_reg_no AS string)            AS business_reg_no
    , CAST(head_office_addr AS string)           AS head_office_addr
    , CAST(related_party_info AS string)         AS related_party_info
    , CAST(paid_in_capital AS decimal(19,0))     AS paid_in_capital
    , CAST(owned_share_qty AS decimal(19,0))     AS owned_share_qty
    , CAST(ownership_ratio AS decimal(19,6))     AS ownership_ratio
    , CAST(voting_share_ratio AS decimal(19,6))  AS voting_share_ratio
    , CAST(effective_from_date AS timestamp)     AS effective_from_date
    , CAST(effective_to_date AS timestamp)       AS effective_to_date
    , CAST(id_sync AS string)                    AS id_sync
    , CAST(is_sync AS int)                       AS is_sync
    , CAST(deleted AS int)                       AS deleted
    , CAST(deleted_reason AS string)             AS deleted_reason
    , CAST(version AS int)                       AS version
    , CAST(effective_start_date AS timestamp)    AS effective_start_date
    , CAST(effective_end_date AS timestamp)      AS effective_end_date
    , CAST(old_id AS string)                     AS old_id
    , CAST(stable_id AS string)                  AS stable_id
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(updated_at AS timestamp)              AS updated_at
    , CAST(created_by_id AS string)              AS created_by_id
    , CAST(created_by_name AS string)            AS created_by_name
    , CAST(updated_by_id AS string)              AS updated_by_id
    , CAST(updated_by_name AS string)            AS updated_by_name
FROM {{ source('source_ecat', 'raw_gms_ids_company_relationship') }}