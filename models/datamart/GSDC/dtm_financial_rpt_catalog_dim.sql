/*
*--------------------------------------------------------------------*
* Program code: dtm_financial_rpt_catalog_dim
* Program name: Dtm Financial Rpt Catalog Dim
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-22		duc.luxuan			Atomic doi co che (scd4a --> scd2) cho atm_fr_catalog,
*									atm_fr_row, atm_fr_column. Sua theo dung:
*									bo hau to _hstr + bo dieu kien ds_snpst_dt (doc thang bang
*									current-state), doi ten cot nguon fr_row_nm/fr_column_nm
*									(giu nguyen alias output fr_row_template_nm/
*									fr_column_template_nm cua Mart nay). Van giu ds_rcrd_st =
*									'ACTIVE' (soft delete flag khong doi).
* 2026-09-25		duc.luxuan			financial_rpt_catalog_code doi sang lay rpt_code (report_cd
*									- ma bao cao nghiep vu). Cot fr_catalog_code (id) doi ten
*									thanh financial_catalog_code, dung lam khoa join cho Fact
*									(report_cd + nam KHONG unique: 1 report_cd/nam co 2 id).
*--------------------------------------------------------------------*
*/

WITH fr_catalog AS (
    SELECT
        fr_catalog_id,
        fr_catalog_code,
        rpt_code,
        fr_catalog_nm,
        rpt_catalog_tp_code,
        enterprise_tp_code,
        src_stm_code,
        fr_year
    FROM {{ ref('atm_fr_catalog') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_REPORT_CATALOG'
),

fr_row_template AS (
    SELECT
        fr_catalog_id,
        fr_row_code,
        row_code,
        row_description_reference,
        fr_row_nm,
        row_index,
        rpt_year
    FROM {{ ref('atm_fr_row') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_RROW'
),

fr_column_template AS (
    SELECT
        fr_catalog_id,
        fr_column_code,
        column_code,
        column_description_reference,
        fr_column_nm,
        column_index,
        rpt_year
    FROM {{ ref('atm_fr_column') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_RCOL'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('IDS_REPORT_CATALOG', "concat(fr_catalog.fr_catalog_code, '|', fr_row_template.fr_row_code, '|', fr_column_template.fr_column_code, '|', fr_catalog.fr_year)") }} AS string) AS financial_rpt_catalog_dim_id,
    CAST(fr_catalog.fr_catalog_code AS string)                      AS financial_catalog_code,
    CAST(fr_catalog.rpt_code AS string)                             AS financial_rpt_catalog_code,
    CAST(fr_row_template.row_code AS string)                        AS row_code,
    CAST(fr_column_template.column_code AS string)                  AS column_code,
    CAST(fr_catalog.fr_year AS string)                              AS fr_year,
    CAST(fr_catalog.fr_catalog_nm AS string)                        AS financial_rpt_catalog_nm,
    CAST(fr_catalog.rpt_catalog_tp_code AS string)                  AS financial_rpt_catalog_tp_code,
    CAST(fr_catalog.enterprise_tp_code AS string)                   AS enterprise_tp_code,
    CAST(fr_row_template.row_description_reference AS string)       AS row_description_reference,
    CAST(fr_column_template.column_description_reference AS string) AS column_description_reference,
    CAST(fr_row_template.fr_row_nm AS string)                       AS fr_row_template_nm,
    CAST(fr_row_template.row_index AS int)                          AS row_index,
    CAST(fr_column_template.fr_column_nm AS string)                 AS fr_column_template_nm,
    CAST(fr_column_template.column_index AS int)                    AS column_index,
    CAST(fr_catalog.src_stm_code AS string)                         AS src_stm_code
FROM fr_catalog
INNER JOIN fr_row_template
    ON fr_row_template.fr_catalog_id = fr_catalog.fr_catalog_id
    AND fr_row_template.rpt_year = fr_catalog.fr_year
INNER JOIN fr_column_template
    ON fr_column_template.fr_catalog_id = fr_catalog.fr_catalog_id
    AND fr_column_template.rpt_year = fr_catalog.fr_year
