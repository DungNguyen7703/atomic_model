/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_files
* Program name: Staging ECAT.FILES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)          AS id
    , CAST(file_name AS string) AS file_name
    , CAST(file_path AS string) AS file_path
    , CAST(ref_type AS string)  AS ref_type
    , CAST(ref_id AS string)    AS ref_id
FROM {{ source('source_ecat', 'raw_files') }}