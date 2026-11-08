/*
*--------------------------------------------------------------------*
* Program code: stg_fims_user_data_permission
* Program name: Staging FIMS.USER_DATA_PERMISSION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                   AS id
    , CAST(userid AS bigint)             AS userid
    , CAST(systemobject AS bigint)       AS systemobject
    , CAST(memberid AS bigint)           AS memberid
    , CAST(datecreated AS timestamp)     AS datecreated
    , CAST(datemodified AS timestamp)    AS datemodified
    , CAST(createdby AS string)          AS createdby
    , CAST(modifyby AS string)           AS modifyby
    , CAST(ssouserid AS string)          AS ssouserid
    , CAST(deleted AS int)               AS deleted
    , CAST(username AS string)           AS username
    , CAST(udpukactivekey AS string)     AS udpukactivekey
    , CAST(ssoprofileunavailable AS int) AS ssoprofileunavailable
FROM {{ source('source_fims', 'raw_user_data_permission') }}