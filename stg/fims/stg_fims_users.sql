/*
*--------------------------------------------------------------------*
* Program code: stg_fims_users
* Program name: Staging FIMS.USERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))                 AS id
    , CAST(deleted AS int)                    AS deleted
    , CAST(datecreated AS date)               AS datecreated
    , CAST(createdby AS string)               AS createdby
    , CAST(datemodified AS date)              AS datemodified
    , CAST(modifyby AS string)                AS modifyby
    , CAST(username AS string)                AS username
    , CAST(displayname AS string)             AS displayname
    , CAST(password AS string)                AS password
    , CAST(status AS int)                     AS status
    , CAST(datelogined AS date)               AS datelogined
    , CAST(datechangepassword AS date)        AS datechangepassword
    , CAST(systemobject AS decimal(18,2))     AS systemobject
    , CAST(orgpassword AS string)             AS orgpassword
    , CAST(iscer AS int)                      AS iscer
    , CAST(email AS string)                   AS email
    , CAST(isdatamigration AS int)            AS isdatamigration
    , CAST(description AS string)             AS description
    , CAST(unitid AS decimal(18,2))           AS unitid
    , CAST(departmentid AS decimal(18,2))     AS departmentid
    , CAST(jobtypeid AS decimal(18,2))        AS jobtypeid
    , CAST(accounttype AS decimal(18,2))      AS accounttype
    , CAST(fundcomid AS decimal(18,2))        AS fundcomid
    , CAST(seccomid AS decimal(18,2))         AS seccomid
    , CAST(bankid AS decimal(18,2))           AS bankid
    , CAST(depcenid AS decimal(18,2))         AS depcenid
    , CAST(stockcenid AS decimal(18,2))       AS stockcenid
    , CAST(indirepcenid AS decimal(18,2))     AS indirepcenid
    , CAST(branchsid AS decimal(18,2))        AS branchsid
    , CAST(countpassfail AS decimal(18,2))    AS countpassfail
    , CAST(isfirstlogin AS int)               AS isfirstlogin
    , CAST(idold AS string)                   AS idold
    , CAST(codeotp AS string)                 AS codeotp
    , CAST(dategenotp AS timestamp)           AS dategenotp
    , CAST(phonenumber AS string)             AS phonenumber
    , CAST(investorid AS bigint)              AS investorid
    , CAST(tradingrepresentativeid AS bigint) AS tradingrepresentativeid
    , CAST(sso_user_id AS string)             AS sso_user_id
FROM {{ source('source_fims', 'raw_users') }}