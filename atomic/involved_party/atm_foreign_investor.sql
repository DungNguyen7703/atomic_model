/*
*--------------------------------------------------------------------*
* Program code: atm_foreign_investor
* Program name: Atomic Foreign Investor
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH inve_all AS (
    SELECT
        transactioncode
        , objecttype
        , name
        , ename
        , sex
        , dateofbirth
        , naid
        , director
        , investortypeid
        , depaccountnumber
        , sysobjecttype
        , seccomaddid
        , bankaddid
        , accountinvescapital
        , bankaddcapid
        , companytypeid
        , statusid
        , description
        , id
        , row_number() over (partition by transactioncode order by id desc) as rn
    FROM {{ ref('ods_fims_investor') }}
),

inve AS (
    SELECT
        transactioncode
        , objecttype
        , name
        , ename
        , sex
        , dateofbirth
        , naid
        , director
        , investortypeid
        , depaccountnumber
        , sysobjecttype
        , seccomaddid
        , bankaddid
        , accountinvescapital
        , bankaddcapid
        , companytypeid
        , statusid
        , description
        , id
    FROM inve_all
    WHERE rn = 1
),

nati AS (
    SELECT
        id
        , sname
    FROM {{ ref('ods_fims_national') }}
),

in_ty AS (
    SELECT
        id
        , sname
    FROM {{ ref('ods_fims_investortype') }}
),

co_ty AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_fims_companytype') }}
),

stat AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_fims_status') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_INVESTOR', "inve.transactioncode") }}        AS foreign_investor_id
    , CAST(inve.transactioncode AS string)                                              AS foreign_investor_code
    , CAST('FIMS_INVESTOR' AS string)                                                   AS src_stm_code
    , CAST(inve.objecttype AS string)                                                   AS investor_object_tp_code
    , CAST(inve.name AS string)                                                         AS full_nm
    , CAST(inve.ename AS string)                                                        AS english_nm
    , CAST(inve.sex AS string)                                                          AS gender_code
    , CAST(inve.dateofbirth AS date)                                                    AS dt_of_birth
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "nati.sname") }}                 AS nationality_id
    , CAST(nati.sname AS string)                                                        AS nationality_code
    , CAST(inve.director AS string)                                                     AS director_full_nm
    , {{ generate_surrogate_key_bigint('FIMS_INVESTORTYPE', "in_ty.sname") }}           AS cl_fims_investor_tp_id
    , CAST(in_ty.sname AS string)                                                       AS cl_fims_investor_tp_code
    , CAST(inve.depaccountnumber AS string)                                             AS depository_account_nbr
    , CAST(inve.sysobjecttype AS string)                                                AS investor_stm_object_tp_code
    , {{ generate_surrogate_key_bigint('FIMS_SECURITIESCOMPANY', "inve.seccomaddid") }} AS sc_id
    , CAST(inve.seccomaddid AS string)                                                  AS sc_code
    , {{ generate_surrogate_key_bigint('FIMS_BANKMONI', "inve.bankaddid") }}            AS custodian_bank_id
    , CAST(inve.bankaddid AS string)                                                    AS custodian_bank_code
    , CAST(inve.accountinvescapital AS string)                                          AS capital_investment_account_nbr
    , {{ generate_surrogate_key_bigint('FIMS_BANKMONI', "inve.bankaddcapid") }}         AS capital_custodian_bank_id
    , CAST(inve.bankaddcapid AS string)                                                 AS capital_custodian_bank_code
    , {{ generate_surrogate_key_bigint('FIMS_COMPANYTYPE', "co_ty.code") }}             AS cl_fims_company_tp_id
    , CAST(co_ty.code AS string)                                                        AS cl_fims_company_tp_code
    , {{ generate_surrogate_key_bigint('FIMS_STATUS', "stat.code") }}                   AS cl_fims_status_id
    , CAST(stat.code AS string)                                                         AS cl_fims_status_code
    , CAST(inve.description AS string)                                                  AS description
    , CAST(inve.id AS string)                                                           AS old_id
FROM inve
    LEFT JOIN nati ON inve.NaId = nati.Id
    LEFT JOIN in_ty ON inve.InvestorTypeId = in_ty.Id
    LEFT JOIN co_ty ON inve.CompanyTypeId = co_ty.Id
    LEFT JOIN stat ON inve.StatusId = stat.Id