-- ────────────────────────────────────────────────────────────
-- Model : gsdc_public_company_flat
-- Type  : Dimension
-- ────────────────────────────────────────────────────────────

SELECT
    public_company_code                 ,
    equity_ticker_symbol                ,
    public_company_nm                   ,
    equity_listing_exchange_code        ,
    equity_listing_exchange_name        ,    
    business_line_level_1_code          ,
    ids_registration_dt                 ,
    public_company_status_code          ,
    src_stm_code                        ,
    classification_business_line_nm     ,
    public_company_english_nm           ,
    enterprise_tp_code                  ,
    enterprise_tp_nm                    ,
    public_company_tp_code              ,
    head_office_province_nm             ,
    operating_status_code               ,
    has_state_ownership_indicator       ,
    charter_capital_amt                 ,
    first_registration_dt               ,
    latest_registration_dt              ,
    latest_registration_province_nm     ,
    ids_registration_indicator          ,
    public_company_form_code            ,
    former_state_owned_indicator        ,
    foreign_direct_investment_indicator ,
    has_parent_company_indicator        ,
    has_subsidiary_indicator            ,
    has_joint_venture_indicator         ,
    ipo_company_indicator               

FROM {{ ref('dtm_public_company_dim')}}_hstr 
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND ds_rcrd_st = 'ACTIVE'
    AND src_stm_code = 'IDS_COMPANY_PROFILES'