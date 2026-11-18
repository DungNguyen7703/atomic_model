/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address SCMS.SC_FIRM_RELATED_PERSON
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-27		claude				Xoa cot province_nm/district_nm/ward_nm, sap lai thu tu cot theo template
*										scms_sc_firm_transaction_office.
*--------------------------------------------------------------------*
*/

WITH sc_fi_re_pe AS (
    SELECT
        id
        , permanent_address
    FROM {{ ref('ods_scms_sc_firm_related_person') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_RELATED_PERSON', "sc_fi_re_pe.id") }} AS ip_id
    , CAST(sc_fi_re_pe.id AS string)                                                     AS ip_code
    , CAST('SCMS_SC_FIRM_RELATED_PERSON' AS string)                                      AS src_stm_code
    , CAST('PERMANENT' AS string)                                                        AS adr_tp_code
    , CAST(sc_fi_re_pe.permanent_address AS string)                                      AS adr_val
    , CAST(NULL AS string)                                                               AS country_id
    , CAST(NULL AS string)                                                               AS country_code
    , CAST(NULL AS string)                                                               AS province_id
    , CAST(NULL AS string)                                                               AS province_code
    , CAST(NULL AS string)                                                               AS district_id
    , CAST(NULL AS string)                                                               AS district_code
    , CAST(NULL AS string)                                                               AS ward_id
    , CAST(NULL AS string)                                                               AS ward_code
FROM sc_fi_re_pe