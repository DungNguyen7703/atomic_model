/*
*--------------------------------------------------------------------*
* Program code: atm_sc_disclosure_securities_offering_item
* Program name: Atomic Securities Company Disclosure Securities Offering Item
* Grain: 1 row / (id, offering_method, offering_target_code)
* Key: id + offering_method + offering_target_code
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*                                       Normalize numeric value (ODS STRING -> DECIMAL(38,x))
*--------------------------------------------------------------------*
*/

{#- danh sách cột số cần chuẩn hóa: (tên cột ODS, kiểu đích) -#}
{% set num_cols = [
    ('par_value', 'decimal(38,10)')
    , ('planned_quantity', 'decimal(38,0)')
    , ('planned_price', 'decimal(38,10)')
    , ('planned_value_at_par', 'decimal(38,10)')
    , ('planned_investor_count', 'decimal(38,0)')
    , ('actual_quantity', 'decimal(38,0)')
    , ('actual_price', 'decimal(38,10)')
    , ('actual_value', 'decimal(38,10)')
    , ('participant_count', 'decimal(38,0)')
    , ('foreign_investor_participant_count', 'decimal(38,0)')
    , ('foreign_investor_issued_value', 'decimal(38,10)')
] %}

WITH it AS (
    SELECT
        id
        , sc_firm_info_id
        , offering_target_code
        , offering_method
        , par_value
        , planned_quantity
        , planned_price
        , planned_value_at_par
        , planned_investor_count
        , target_description
        , exchange_purpose
        , expected_start_date
        , expected_end_date
        , actual_quantity
        , actual_price
        , actual_value
        , participant_count
        , foreign_investor_participant_count
        , foreign_investor_issued_value
    FROM {{ ref('ods_scms_disclosure_securities_offering_item') }}
)

/* B1: bỏ khoảng trắng (kể cả NBSP) */
, it_cln AS (
    SELECT
        it.*
        {%- for c, t in num_cols %}
        , regexp_replace(trim(CAST(it.{{ c }} AS string)), '[\\s\\u00A0]', '') AS {{ c }}_cln
        {%- endfor %}
    FROM it
)

/* B2: tách dấu | phần định trị | số mũ. Không khớp thì regexp_extract trả về '' */
, it_prs AS (
    SELECT
        it_cln.*
        {%- for c, t in num_cols %}
        , regexp_extract({{ c }}_cln, '^([+-]?)([0-9.,]+)([eE][+-]?[0-9]+)?$', 1) AS {{ c }}_sgn
        , regexp_extract({{ c }}_cln, '^([+-]?)([0-9.,]+)([eE][+-]?[0-9]+)?$', 2) AS {{ c }}_mnt
        , regexp_extract({{ c }}_cln, '^([+-]?)([0-9.,]+)([eE][+-]?[0-9]+)?$', 3) AS {{ c }}_exp
        {%- endfor %}
    FROM it_cln
)

/* B3: chuẩn hóa dấu phân cách và cast sang số (sai định dạng -> NULL) */
, it_num AS (
    SELECT
        it_prs.*
        {%- for c, t in num_cols %}
        , TRY_CAST(
            concat(
                {{ c }}_sgn
                , CASE
                    -- 123456789
                    WHEN {{ c }}_mnt RLIKE '^[0-9]+$'
                        THEN {{ c }}_mnt
                    -- 1.5 | .5          (một dấu '.' => thập phân)
                    WHEN {{ c }}_mnt RLIKE '^[0-9]*[.][0-9]+$'
                        THEN {{ c }}_mnt
                    -- 123,456,789 | 123,456.789 | 1,234
                    WHEN {{ c }}_mnt RLIKE '^[0-9]{1,3}(,[0-9]{3})+([.][0-9]+)?$'
                        THEN replace({{ c }}_mnt, ',', '')
                    -- 123.456.789 | 123.456,789
                    WHEN {{ c }}_mnt RLIKE '^[0-9]{1,3}([.][0-9]{3})+(,[0-9]+)?$'
                        THEN replace(replace({{ c }}_mnt, '.', ''), ',', '.')
                    -- 1,5 | ,5          (một dấu ',' không theo nhóm 3 => thập phân)
                    WHEN {{ c }}_mnt RLIKE '^[0-9]*,[0-9]+$'
                        THEN replace({{ c }}_mnt, ',', '.')
                  END
                , {{ c }}_exp
            ) AS {{ t }}
          ) AS {{ c }}_num
        {%- endfor %}
    FROM it_prs
)

, sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_DISCLOSURE_SECURITIES_OFFERING_ITEM', "concat_ws('-', cast(it_num.id AS string), coalesce(it_num.offering_method, ''), coalesce(it_num.offering_target_code, ''))") }} AS sc_disclosure_securities_offering_item_id
    , CAST(concat_ws('-', cast(it_num.id AS string), coalesce(it_num.offering_method, ''), coalesce(it_num.offering_target_code, '')) AS string) AS sc_disclosure_securities_offering_item_code
    , CAST('SCMS_DISCLOSURE_SECURITIES_OFFERING' AS string)                                    AS src_stm_code
    -- FK về bảng cha: cùng công thức với sc_disclosure_securities_offering_id của atm_sc_disclosure_securities_offering
    , {{ generate_surrogate_key_bigint('SCMS_DISCLOSURE_SECURITIES_OFFERING', "it_num.id") }}  AS sc_disclosure_securities_offering_id
    , CAST(it_num.id AS string)                                                                AS sc_disclosure_securities_offering_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}               AS sc_id
    , CAST(sc_fi_in.code AS string)                                                           AS sc_code
    , CAST(it_num.offering_target_code AS string)                                              AS offering_target_tp_code
    , CAST(it_num.offering_method AS string)                                                   AS offering_method
    , it_num.par_value_num                                                                     AS par_val_amt
    , it_num.planned_quantity_num                                                              AS planned_quantity
    , it_num.planned_price_num                                                                 AS planned_price_amt
    , it_num.planned_value_at_par_num                                                          AS planned_val_at_par_amt
    , it_num.planned_investor_count_num                                                        AS planned_investor_count
    , CAST(it_num.target_description AS string)                                                AS target_description
    , CAST(it_num.exchange_purpose AS string)                                                  AS exchange_purpose
    , try_cast(it_num.expected_start_date AS date)                                             AS expected_start_dt
    , try_cast(it_num.expected_end_date AS date)                                               AS expected_end_dt
    , it_num.actual_quantity_num                                                               AS actual_quantity
    , it_num.actual_price_num                                                                  AS actual_price_amt
    , it_num.actual_value_num                                                                  AS actual_val_amt
    , it_num.participant_count_num                                                             AS participant_count
    , it_num.foreign_investor_participant_count_num                                            AS foreign_investor_participant_count
    , it_num.foreign_investor_issued_value_num                                                 AS foreign_investor_issued_val_amt
FROM it_num
    LEFT JOIN sc_fi_in ON it_num.sc_firm_info_id = sc_fi_in.id
