/*
*--------------------------------------------------------------------*
* Program code: atm_cl_securities_company_position
* Program name: Atomic Classification Securities Company Position
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ca_po AS (
    SELECT
        position_code
        , position_name
        , position_group
        , note
        , representative
        , board_member
        , branch_director
        , ecatalog_id
    FROM {{ ref('ods_scms_cat_position') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_CAT_POSITION', "ca_po.position_code") }} AS cl_sc_position_id
    , CAST(ca_po.position_code AS string)                                           AS cl_sc_position_code
    , CAST('SCMS_CAT_POSITION' AS string)                                           AS src_stm_code
    , CAST(ca_po.position_name AS string)                                           AS cl_sc_position_nm
    , CAST(ca_po.position_group AS string)                                          AS position_group
    , CAST(ca_po.note AS string)                                                    AS note
    , CAST(ca_po.representative AS int)                                             AS representative_ind
    , CAST(ca_po.board_member AS int)                                               AS board_member_ind
    , CAST(ca_po.branch_director AS int)                                            AS branch_director_ind
    , CAST(ca_po.ecatalog_id AS string)                                             AS ecatalog_id
FROM ca_po