/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_code_sequence_counter
* Program name: Staging THANHTRA.CODE_SEQUENCE_COUNTER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(prefix AS string)     AS prefix
    , CAST(year_key AS string) AS year_key
    , CAST(last_seq AS bigint) AS last_seq
FROM {{ source('source_thanhtra', 'raw_code_sequence_counter') }}