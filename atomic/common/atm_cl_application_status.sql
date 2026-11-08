/*
*--------------------------------------------------------------------*
* Program code: atm_cl_application_status
* Program name: Atomic Classification Application Status
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ap_st AS (
    SELECT
        id
        , status_code
        , status_name
        , label
        , description
        , sort_order
        , is_active
        , is_original_data
    FROM {{ ref('ods_nhnck_application_statuses') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_APPLICATION_STATUSES', "ap_st.status_code") }} AS cl_application_status_id
    , CAST(ap_st.status_code AS string)                                                    AS cl_application_status_code
    , CAST('NHNCK_APPLICATION_STATUSES' AS string)                                         AS src_stm_code
    , CAST(ap_st.status_name AS string)                                                    AS cl_application_status_nm
    , CAST(ap_st.label AS string)                                                          AS label
    , CAST(ap_st.description AS string)                                                    AS description
    , CAST(ap_st.sort_order AS int)                                                        AS sort_order
    , CAST(ap_st.is_active AS string)                                                      AS active_ind
    , CAST(ap_st.is_original_data AS string)                                               AS original_data_ind
FROM ap_st