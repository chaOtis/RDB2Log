CREATE PROCEDURE [dbo].[sp_compute_roles]
@database1 varchar(128) = NULL

AS

BEGIN

DECLARE @sqltext nvarchar(4000)

DECLARE @database varchar(128), @tableschema varchar(128), @tablename varchar(128), @columnname varchar(128), @datatype varchar(128)
DECLARE @accuracy FLOAT, @sufficiency FLOAT, @precision FLOAT, @consistency FLOAT, @completeness FLOAT, @objectivity FLOAT
DECLARE @security FLOAT, @uniqueness FLOAT, @informativeness FLOAT, @integrity FLOAT, @conciseness FLOAT, @currency FLOAT

-- lower thresholds
DECLARE @accuracy_lo FLOAT, @sufficiency_lo FLOAT, @precision_lo FLOAT, @consistency_lo FLOAT, @completeness_lo FLOAT, @objectivity_lo FLOAT
DECLARE @security_lo FLOAT, @uniqueness_lo FLOAT, @informativeness_lo FLOAT, @integrity_lo FLOAT, @conciseness_lo FLOAT, @currency_lo FLOAT

-- upper thresholds
DECLARE @accuracy_up FLOAT, @sufficiency_up FLOAT, @precision_up FLOAT, @consistency_up FLOAT, @completeness_up FLOAT, @objectivity_up FLOAT
DECLARE @security_up FLOAT, @uniqueness_up FLOAT, @informativeness_up FLOAT, @integrity_up FLOAT, @conciseness_up FLOAT, @currency_up FLOAT

DECLARE @caseID varchar(255), @activity varchar(255), @timestamp varchar(255), @event varchar(255), @resource varchar(255), @eventData varchar(255), @caseData varchar(255)

DECLARE csr CURSOR LOCAL FAST_FORWARD FOR
SELECT [tablecatalog], [tableschema], [tablename], [columnname], [datatype],
  [accuracy], [sufficiency], [precision], [consistency], [completeness], [objectivity],
  [security], [uniqueness], [informativeness], [integrity], [conciseness], [currency]
FROM [DBA].[dbo].[ColumnQuality]

OPEN csr
FETCH csr INTO @database, @tableschema, @tablename, @columnname, @datatype, @accuracy, @sufficiency, @precision, @consistency, @completeness, @objectivity,
               @security, @uniqueness, @informativeness, @integrity, @conciseness, @currency
WHILE @@FETCH_STATUS = 0
BEGIN

  -- caseID
  SELECT @accuracy_lo = [accuracy_lower], @sufficiency_lo = [sufficiency_lower], @precision_lo = [precision_lower], @consistency_lo = [consistency_lower],
         @completeness_lo = [completeness_lower], @objectivity_lo = [objectivity_lower], @security_lo = [security_lower], @uniqueness_lo = [uniqueness_lower],
         @informativeness_lo = [informativeness_lower], @integrity_lo = [integrity_lower], @conciseness_lo = [conciseness_lower], @currency_lo = [currency_lower]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'caseID'

  SELECT @accuracy_up = [accuracy_upper], @sufficiency_up = [sufficiency_upper], @precision_up = [precision_upper], @consistency_up = [consistency_upper],
         @completeness_up = [completeness_upper], @objectivity_up = [objectivity_upper], @security_up = [security_upper], @uniqueness_up = [uniqueness_upper],
         @informativeness_up = [informativeness_upper], @integrity_up = [integrity_upper], @conciseness_up = [conciseness_upper], @currency_up = [currency_upper]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'caseID'

  SET @caseID = '1'
  IF (@accuracy < @accuracy_lo OR @sufficiency < @sufficiency_lo OR @precision < @precision_lo OR @consistency < @consistency_lo OR
      @completeness < @completeness_lo OR @objectivity < @objectivity_lo OR @security < @security_lo OR @uniqueness < @uniqueness_lo OR
      @informativeness < @informativeness_lo OR @integrity < @integrity_lo OR @conciseness < @conciseness_lo OR @currency < @currency_lo OR
      @accuracy > @accuracy_up OR @sufficiency > @sufficiency_up OR @precision > @precision_up OR @consistency > @consistency_up OR
      @completeness > @completeness_up OR @objectivity > @objectivity_up OR @security > @security_up OR @uniqueness > @uniqueness_up OR
      @informativeness > @informativeness_up OR @integrity > @integrity_up OR @conciseness > @conciseness_up OR @currency > @currency_up)
    SET @caseID = '0'


  -- activity
  SELECT @accuracy_lo = [accuracy_lower], @sufficiency_lo = [sufficiency_lower], @precision_lo = [precision_lower], @consistency_lo = [consistency_lower],
         @completeness_lo = [completeness_lower], @objectivity_lo = [objectivity_lower], @security_lo = [security_lower], @uniqueness_lo = [uniqueness_lower],
         @informativeness_lo = [informativeness_lower], @integrity_lo = [integrity_lower], @conciseness_lo = [conciseness_lower], @currency_lo = [currency_lower]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'activity'

  SELECT @accuracy_up = [accuracy_upper], @sufficiency_up = [sufficiency_upper], @precision_up = [precision_upper], @consistency_up = [consistency_upper],
         @completeness_up = [completeness_upper], @objectivity_up = [objectivity_upper], @security_up = [security_upper], @uniqueness_up = [uniqueness_upper],
         @informativeness_up = [informativeness_upper], @integrity_up = [integrity_upper], @conciseness_up = [conciseness_upper], @currency_up = [currency_upper]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'activity'

  SET @activity = '1'
  IF (@accuracy < @accuracy_lo OR @sufficiency < @sufficiency_lo OR @precision < @precision_lo OR @consistency < @consistency_lo OR
      @completeness < @completeness_lo OR @objectivity < @objectivity_lo OR @security < @security_lo OR @uniqueness < @uniqueness_lo OR
      @informativeness < @informativeness_lo OR @integrity < @integrity_lo OR @conciseness < @conciseness_lo OR @currency < @currency_lo OR
      @accuracy > @accuracy_up OR @sufficiency > @sufficiency_up OR @precision > @precision_up OR @consistency > @consistency_up OR
      @completeness > @completeness_up OR @objectivity > @objectivity_up OR @security > @security_up OR @uniqueness > @uniqueness_up OR
      @informativeness > @informativeness_up OR @integrity > @integrity_up OR @conciseness > @conciseness_up OR @currency > @currency_up)
    SET @activity = '0'


  -- timestamp
  SELECT @accuracy_lo = [accuracy_lower], @sufficiency_lo = [sufficiency_lower], @precision_lo = [precision_lower], @consistency_lo = [consistency_lower],
         @completeness_lo = [completeness_lower], @objectivity_lo = [objectivity_lower], @security_lo = [security_lower], @uniqueness_lo = [uniqueness_lower],
         @informativeness_lo = [informativeness_lower], @integrity_lo = [integrity_lower], @conciseness_lo = [conciseness_lower], @currency_lo = [currency_lower]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'timestamp'

  SELECT @accuracy_up = [accuracy_upper], @sufficiency_up = [sufficiency_upper], @precision_up = [precision_upper], @consistency_up = [consistency_upper],
         @completeness_up = [completeness_upper], @objectivity_up = [objectivity_upper], @security_up = [security_upper], @uniqueness_up = [uniqueness_upper],
         @informativeness_up = [informativeness_upper], @integrity_up = [integrity_upper], @conciseness_up = [conciseness_upper], @currency_up = [currency_upper]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'timestamp'

  SET @timestamp = '1'
  IF (@accuracy < @accuracy_lo OR @sufficiency < @sufficiency_lo OR @precision < @precision_lo OR @consistency < @consistency_lo OR
      @completeness < @completeness_lo OR @objectivity < @objectivity_lo OR @security < @security_lo OR @uniqueness < @uniqueness_lo OR
      @informativeness < @informativeness_lo OR @integrity < @integrity_lo OR @conciseness < @conciseness_lo OR @currency < @currency_lo OR
      @accuracy > @accuracy_up OR @sufficiency > @sufficiency_up OR @precision > @precision_up OR @consistency > @consistency_up OR
      @completeness > @completeness_up OR @objectivity > @objectivity_up OR @security > @security_up OR @uniqueness > @uniqueness_up OR
      @informativeness > @informativeness_up OR @integrity > @integrity_up OR @conciseness > @conciseness_up OR @currency > @currency_up)
    SET @timestamp = '0'
  IF @datatype != 'datetime2' AND @datatype != 'datetime'
    SET @timestamp = '0'


  -- event
  SELECT @accuracy_lo = [accuracy_lower], @sufficiency_lo = [sufficiency_lower], @precision_lo = [precision_lower], @consistency_lo = [consistency_lower],
         @completeness_lo = [completeness_lower], @objectivity_lo = [objectivity_lower], @security_lo = [security_lower], @uniqueness_lo = [uniqueness_lower],
         @informativeness_lo = [informativeness_lower], @integrity_lo = [integrity_lower], @conciseness_lo = [conciseness_lower], @currency_lo = [currency_lower]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'event'

  SELECT @accuracy_up = [accuracy_upper], @sufficiency_up = [sufficiency_upper], @precision_up = [precision_upper], @consistency_up = [consistency_upper],
         @completeness_up = [completeness_upper], @objectivity_up = [objectivity_upper], @security_up = [security_upper], @uniqueness_up = [uniqueness_upper],
         @informativeness_up = [informativeness_upper], @integrity_up = [integrity_upper], @conciseness_up = [conciseness_upper], @currency_up = [currency_upper]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'event'

  SET @event = '1'
  IF (@accuracy < @accuracy_lo OR @sufficiency < @sufficiency_lo OR @precision < @precision_lo OR @consistency < @consistency_lo OR
      @completeness < @completeness_lo OR @objectivity < @objectivity_lo OR @security < @security_lo OR @uniqueness < @uniqueness_lo OR
      @informativeness < @informativeness_lo OR @integrity < @integrity_lo OR @conciseness < @conciseness_lo OR @currency < @currency_lo OR
      @accuracy > @accuracy_up OR @sufficiency > @sufficiency_up OR @precision > @precision_up OR @consistency > @consistency_up OR
      @completeness > @completeness_up OR @objectivity > @objectivity_up OR @security > @security_up OR @uniqueness > @uniqueness_up OR
      @informativeness > @informativeness_up OR @integrity > @integrity_up OR @conciseness > @conciseness_up OR @currency > @currency_up)
    SET @event = '0'
  IF @datatype != 'datetime2' AND @datatype != 'datetime'
    SET @event = '0'


  -- resource
  SELECT @accuracy_lo = [accuracy_lower], @sufficiency_lo = [sufficiency_lower], @precision_lo = [precision_lower], @consistency_lo = [consistency_lower],
         @completeness_lo = [completeness_lower], @objectivity_lo = [objectivity_lower], @security_lo = [security_lower], @uniqueness_lo = [uniqueness_lower],
         @informativeness_lo = [informativeness_lower], @integrity_lo = [integrity_lower], @conciseness_lo = [conciseness_lower], @currency_lo = [currency_lower]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'resource'

  SELECT @accuracy_up = [accuracy_upper], @sufficiency_up = [sufficiency_upper], @precision_up = [precision_upper], @consistency_up = [consistency_upper],
         @completeness_up = [completeness_upper], @objectivity_up = [objectivity_upper], @security_up = [security_upper], @uniqueness_up = [uniqueness_upper],
         @informativeness_up = [informativeness_upper], @integrity_up = [integrity_upper], @conciseness_up = [conciseness_upper], @currency_up = [currency_upper]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'resource'

  SET @resource = '1'
  IF (@accuracy < @accuracy_lo OR @sufficiency < @sufficiency_lo OR @precision < @precision_lo OR @consistency < @consistency_lo OR
      @completeness < @completeness_lo OR @objectivity < @objectivity_lo OR @security < @security_lo OR @uniqueness < @uniqueness_lo OR
      @informativeness < @informativeness_lo OR @integrity < @integrity_lo OR @conciseness < @conciseness_lo OR @currency < @currency_lo OR
      @accuracy > @accuracy_up OR @sufficiency > @sufficiency_up OR @precision > @precision_up OR @consistency > @consistency_up OR
      @completeness > @completeness_up OR @objectivity > @objectivity_up OR @security > @security_up OR @uniqueness > @uniqueness_up OR
      @informativeness > @informativeness_up OR @integrity > @integrity_up OR @conciseness > @conciseness_up OR @currency > @currency_up)
    SET @resource = '0'

  -- eventData
  SELECT @accuracy_lo = [accuracy_lower], @sufficiency_lo = [sufficiency_lower], @precision_lo = [precision_lower], @consistency_lo = [consistency_lower],
         @completeness_lo = [completeness_lower], @objectivity_lo = [objectivity_lower], @security_lo = [security_lower], @uniqueness_lo = [uniqueness_lower],
         @informativeness_lo = [informativeness_lower], @integrity_lo = [integrity_lower], @conciseness_lo = [conciseness_lower], @currency_lo = [currency_lower]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'eventData'

  SELECT @accuracy_up = [accuracy_upper], @sufficiency_up = [sufficiency_upper], @precision_up = [precision_upper], @consistency_up = [consistency_upper],
         @completeness_up = [completeness_upper], @objectivity_up = [objectivity_upper], @security_up = [security_upper], @uniqueness_up = [uniqueness_upper],
         @informativeness_up = [informativeness_upper], @integrity_up = [integrity_upper], @conciseness_up = [conciseness_upper], @currency_up = [currency_upper]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'eventData'

  SET @eventData = '1'
  IF (@accuracy < @accuracy_lo OR @sufficiency < @sufficiency_lo OR @precision < @precision_lo OR @consistency < @consistency_lo OR
      @completeness < @completeness_lo OR @objectivity < @objectivity_lo OR @security < @security_lo OR @uniqueness < @uniqueness_lo OR
      @informativeness < @informativeness_lo OR @integrity < @integrity_lo OR @conciseness < @conciseness_lo OR @currency < @currency_lo OR
      @accuracy > @accuracy_up OR @sufficiency > @sufficiency_up OR @precision > @precision_up OR @consistency > @consistency_up OR
      @completeness > @completeness_up OR @objectivity > @objectivity_up OR @security > @security_up OR @uniqueness > @uniqueness_up OR
      @informativeness > @informativeness_up OR @integrity > @integrity_up OR @conciseness > @conciseness_up OR @currency > @currency_up)
    SET @eventData = '0'

  -- caseData
  SELECT @accuracy_lo = [accuracy_lower], @sufficiency_lo = [sufficiency_lower], @precision_lo = [precision_lower], @consistency_lo = [consistency_lower],
         @completeness_lo = [completeness_lower], @objectivity_lo = [objectivity_lower], @security_lo = [security_lower], @uniqueness_lo = [uniqueness_lower],
         @informativeness_lo = [informativeness_lower], @integrity_lo = [integrity_lower], @conciseness_lo = [conciseness_lower], @currency_lo = [currency_lower]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'caseData'

  SELECT @accuracy_up = [accuracy_upper], @sufficiency_up = [sufficiency_upper], @precision_up = [precision_upper], @consistency_up = [consistency_upper],
         @completeness_up = [completeness_upper], @objectivity_up = [objectivity_upper], @security_up = [security_upper], @uniqueness_up = [uniqueness_upper],
         @informativeness_up = [informativeness_upper], @integrity_up = [integrity_upper], @conciseness_up = [conciseness_upper], @currency_up = [currency_upper]
  FROM [DBA].[dbo].[RoleConditions] WHERE [role] = 'caseData'

  SET @caseData = '1'
  IF (@accuracy < @accuracy_lo OR @sufficiency < @sufficiency_lo OR @precision < @precision_lo OR @consistency < @consistency_lo OR
      @completeness < @completeness_lo OR @objectivity < @objectivity_lo OR @security < @security_lo OR @uniqueness < @uniqueness_lo OR
      @informativeness < @informativeness_lo OR @integrity < @integrity_lo OR @conciseness < @conciseness_lo OR @currency < @currency_lo OR
      @accuracy > @accuracy_up OR @sufficiency > @sufficiency_up OR @precision > @precision_up OR @consistency > @consistency_up OR
      @completeness > @completeness_up OR @objectivity > @objectivity_up OR @security > @security_up OR @uniqueness > @uniqueness_up OR
      @informativeness > @informativeness_up OR @integrity > @integrity_up OR @conciseness > @conciseness_up OR @currency > @currency_up)
    SET @caseData = '0'

	-- save values
	SET @sqltext = 'UPDATE [DBA].[dbo].[ColumnRoles] '
  + 'SET [caseID] = ' + @caseID
  + ', [activity] = ' + @activity
  + ', [timestamp] = ' + @timestamp
  + ', [event] = ' + @event
  + ', [resource] = ' + @resource
  + ', [eventData] = ' + @eventData
  + ', [caseData] = ' + @caseData
	+ ' WHERE [tablecatalog] = ''' + @database + ''''
	+ ' AND [tableschema] = ''' + @tableschema + ''''
	+ ' AND [tablename] = ''' + @tablename + ''''
	+ ' AND [columnname] = ''' + @columnname + ''''
	EXECUTE(@sqltext)

 	-- now get another row from the cursor
	FETCH csr INTO @database, @tableschema, @tablename, @columnname, @datatype, @accuracy, @sufficiency, @precision, @consistency, @completeness, @objectivity,
                 @security, @uniqueness, @informativeness, @integrity, @conciseness, @currency
END

CLOSE csr
DEALLOCATE csr

RETURN 0

END