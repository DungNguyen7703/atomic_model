/*
*--------------------------------------------------------------------*
* Program code: dtm_government_bond_term_dim
* Program name: Government Bond Term Dimension
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-07		claude			[NEW] Tao model theo LLD DTM_TKNB_government_bond_term_dim_HNX_GOV_BOND_OFFERING (836eb5bb):
*									1 dong/ky han nguyen van (bond_term) cua dot dau thau TPCP; lay gia tri khac nhau cua
*									gov_bond_bidding_result, bo NULL, issue_dt <= :etl_date (khong chan duoi - danh muc tich luy).
*--------------------------------------------------------------------*
*/

WITH bidding_result AS (
    SELECT DISTINCT
        bond_term,
        src_stm_code
    FROM {{ ref('atm_gov_bond_bidding_result') }}
    WHERE src_stm_code = 'HNX_GOV_BOND_OFFERING'
        AND bond_term IS NOT NULL
        AND issue_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
)

SELECT
    CAST({{ generate_surrogate_key_bigint('HNX_GOV_BOND_OFFERING', 'bond_term') }} AS string) AS government_bond_term_dim_id,
    CAST(bond_term AS string)                                                                 AS bond_term,
    CAST(CASE WHEN LOWER(bond_term) LIKE '%tuần%' THEN CAST(REGEXP_EXTRACT(bond_term, '[0-9]+', 0) AS DECIMAL(10,4)) / 52.0
              WHEN LOWER(bond_term) LIKE '%tháng%' THEN CAST(REGEXP_EXTRACT(bond_term, '[0-9]+', 0) AS DECIMAL(10,4)) / 12.0
              ELSE CAST(REGEXP_EXTRACT(bond_term, '[0-9]+', 0) AS DECIMAL(10,4)) END AS decimal(10,4)) AS bond_term_years,
    CAST(CASE WHEN LOWER(bond_term) LIKE '%tuần%' THEN 'WEEK'
              WHEN LOWER(bond_term) LIKE '%tháng%' THEN 'MONTH'
              ELSE 'YEAR' END AS string)                            AS bond_term_unit,
    CAST(src_stm_code AS string)                                    AS src_stm_code
FROM bidding_result
