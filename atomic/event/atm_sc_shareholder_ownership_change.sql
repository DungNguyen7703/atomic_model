/*
*--------------------------------------------------------------------*
* Program code: atm_sc_shareholder_ownership_change
* Program name: Atomic Securities Company Shareholder Ownership Change
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_sh_ow_ch AS (
    SELECT
        id
        , created_at
        , sc_firm_info_id
        , shareholder_id
        , transaction_type
        , data_source
        , capital_before
        , ratio_before
        , capital_after
        , ratio_after
        , effective_date
        , document_number
        , attachment_path
        , note
    FROM {{ ref('ods_scms_sc_firm_shareholder_ownership_change') }}
    WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SHAREHOLDER_OWNERSHIP_CHANGE', "sc_fi_sh_ow_ch.id") }} AS sc_shareholder_ownership_change_id
    , CAST(sc_fi_sh_ow_ch.id AS string)                                                                   AS sc_shareholder_ownership_change_code
    , CAST('SCMS_SC_FIRM_SHAREHOLDER_OWNERSHIP_CHANGE' AS string)                                         AS src_stm_code
    , CAST(sc_fi_sh_ow_ch.created_at AS date)                                                             AS data_dt
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_sh_ow_ch.sc_firm_info_id") }}          AS sc_id
    , CAST(sc_fi_sh_ow_ch.sc_firm_info_id AS string)                                                      AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SHAREHOLDER', "sc_fi_sh_ow_ch.shareholder_id") }}    AS sc_shareholder_id
    , CAST(sc_fi_sh_ow_ch.shareholder_id AS string)                                                       AS sc_shareholder_code
    , CAST(sc_fi_sh_ow_ch.transaction_type AS string)                                                     AS shareholder_transaction_tp_code
    , CAST(sc_fi_sh_ow_ch.data_source AS string)                                                          AS data_src
    , CAST(sc_fi_sh_ow_ch.capital_before AS decimal(23,2))                                                AS capital_before
    , CAST(sc_fi_sh_ow_ch.ratio_before AS decimal(5,2))                                                   AS ratio_before
    , CAST(sc_fi_sh_ow_ch.capital_after AS decimal(23,2))                                                 AS capital_after
    , CAST(sc_fi_sh_ow_ch.ratio_after AS decimal(5,2))                                                    AS ratio_after
    , CAST(sc_fi_sh_ow_ch.effective_date AS date)                                                          AS effective_dt
    , CAST(sc_fi_sh_ow_ch.document_number AS string)                                                      AS document_nbr
    , CAST(sc_fi_sh_ow_ch.attachment_path AS string)                                                      AS attachment_path
    , CAST(sc_fi_sh_ow_ch.note AS string)                                                                 AS note
FROM sc_fi_sh_ow_ch