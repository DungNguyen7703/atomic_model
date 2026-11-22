/*
*--------------------------------------------------------------------*
* Program code: atm_sc_report_sheet_column
* Program name: Atomic Securities Company Report Sheet Column
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[MOI] Theo lld_SCMS_FORM_SHEET_COLUMN.yaml - Sinh moi. Nguon ods_scms_form_sheet_column.
*                                       FK hash truc tiep theo ID ky thuat nguon, khong crosswalk.
* 2026-11-13		claude		[DT-Review] CAST int->bigint (nguon NUMBER(10,0)/(18,0)): width_nbr
*--------------------------------------------------------------------*
*/

WITH fo_sh_co AS (
    SELECT
        id
        , form_sheet_id
        , column_code
        , column_name
        , name_format
        , color
        , alignment
        , frozen_column
        , locked_column
        , description
        , legacy_column_code
        , sync_column_code
        , hidden_column
        , required
        , editable
        , formula
        , format
        , width
        , data_type
    FROM {{ ref('ods_scms_form_sheet_column') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_FORM_SHEET_COLUMN', "fo_sh_co.id") }}     AS sc_rpt_sheet_column_id
    , CAST(fo_sh_co.id AS string)                                                      AS sc_rpt_sheet_column_code
    , CAST('SCMS_FORM_SHEET_COLUMN' AS string)                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_SHEET', "fo_sh_co.form_sheet_id") }} AS sc_rpt_sheet_id
    , CAST(fo_sh_co.form_sheet_id AS string)                                           AS sc_rpt_sheet_code
    , CAST(fo_sh_co.column_code AS string)                                             AS column_code
    , CAST(fo_sh_co.column_name AS string)                                             AS column_nm
    , CAST(fo_sh_co.name_format AS string)                                             AS nm_format_code
    , CAST(fo_sh_co.color AS string)                                                   AS color
    , CAST(fo_sh_co.alignment AS string)                                               AS alignment
    , CAST(fo_sh_co.frozen_column AS int)                                              AS frozen_column_ind
    , CAST(fo_sh_co.locked_column AS int)                                              AS locked_column_ind
    , CAST(fo_sh_co.description AS string)                                             AS description
    , CAST(fo_sh_co.legacy_column_code AS string)                                      AS legacy_column_code
    , CAST(fo_sh_co.sync_column_code AS string)                                        AS sync_column_code
    , CAST(fo_sh_co.hidden_column AS int)                                              AS hidden_column_ind
    , CAST(fo_sh_co.required AS int)                                                   AS required_ind
    , CAST(fo_sh_co.editable AS int)                                                   AS editable_ind
    , CAST(fo_sh_co.formula AS string)                                                 AS formula
    , CAST(fo_sh_co.format AS string)                                                  AS format
    , CAST(fo_sh_co.width AS int)                                                      AS width_nbr
    , CAST(fo_sh_co.data_type AS string)                                               AS data_tp_code
FROM fo_sh_co
