/*
*--------------------------------------------------------------------*
* Program code: ods_ids_company_tender_offer
* Program name: ODS IDS.COMPANY_TENDER_OFFER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , company_profile_id
    , tender_offeror_name_vi
    , tender_offeror_name_en
    , securities_agent_name_vi
    , securities_agent_name_en
    , offeror_id_no
    , offeror_relationship
    , planned_offer_from_date
    , planned_offer_to_date
    , pre_offer_share_qty
    , pre_offer_share_ratio
    , planned_offer_share_qty
    , planned_offer_share_ratio
    , planned_offer_price
    , acquired_share_qty
    , acquired_share_ratio
    , post_offer_share_qty
    , post_offer_share_ratio
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , id_sync
FROM {{ ref('stg_ids_company_tender_offer') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')