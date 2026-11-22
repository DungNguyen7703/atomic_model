/*
*--------------------------------------------------------------------*
* Program code: atm_trading_authorization
* Program name: Atomic Trading Authorization
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH fmc_secu AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_fms_securities') }}
),

tr_au AS (
    SELECT
        id
        , systemobject
        , fundcomid
        , seccomid
        , investorid
        , authorizationtypeid
        , sdate
        , edate
        , note
        , tradingrepresentativeid
    FROM {{ ref('ods_fims_tradingauthorization') }}
),

inve AS (
    SELECT
        id
        , transactioncode
    FROM {{ ref('ods_fims_investor') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_TRADINGAUTHORIZATION', "tr_au.id") }}      AS trading_authorization_id
    , CAST(tr_au.id AS string)                                                        AS trading_authorization_code
    , CAST('FIMS_TRADINGAUTHORIZATION' AS string)                                     AS src_stm_code
    , CAST(tr_au.systemobject AS bigint)                                              AS stm_object_tp_code
    , {{ generate_surrogate_key_bigint('FMS_SECURITIES', "fmc_secu.code") }}          AS fmc_id
    , CAST(fmc_secu.code AS string)                                                   AS fmc_code
    , {{ generate_surrogate_key_bigint('FIMS_SECURITIESCOMPANY', "tr_au.seccomid") }} AS sc_id
    , CAST(tr_au.seccomid AS string)                                                  AS sc_code
    , {{ generate_surrogate_key_bigint('FIMS_INVESTOR', "inve.transactioncode") }}    AS foreign_investor_id
    , CAST(inve.transactioncode AS string)                                            AS foreign_investor_code
    , CAST(tr_au.authorizationtypeid AS bigint)                                       AS authorization_tp_code
    , CAST(tr_au.sdate AS date)                                                       AS effective_start_dt
    , CAST(tr_au.edate AS date)                                                       AS effective_end_dt
    , CAST(tr_au.note AS string)                                                      AS note
    , CAST(tr_au.tradingrepresentativeid AS bigint)                                   AS trading_representative_id
FROM tr_au
    LEFT JOIN inve ON tr_au.investorid = inve.id
    LEFT JOIN fmc_secu ON tr_au.fundcomid = fmc_secu.id
