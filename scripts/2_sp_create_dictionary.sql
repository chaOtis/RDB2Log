CREATE PROCEDURE [dbo].[sp_create_dictionary]
@database varchar(128) = NULL

AS

BEGIN

IF @database IS NULL
	SET @database = db_name()

DECLARE @df varchar(255)
SET @df = 'master.dbo.NLD'

DECLARE @sqltext nvarchar(4000)

IF object_id(N'DBA..[Constraints]') IS NOT NULL
DELETE FROM [DBA].[dbo].[Constraints]


-- now populate Constraints
SET @sqltext = 'INSERT INTO [DBA].[dbo].[Constraints] ([tableschema], [tablecatalog], [tablename],[columnname], [constrainttype]) '
+ 'SELECT A.[TABLE_SCHEMA], A.[TABLE_CATALOG], A.[TABLE_NAME], A.[COLUMN_NAME], '
+ 'B.[CONSTRAINT_TYPE] '
+ 'FROM ' + @database + '.[INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE] A '
+ 'INNER JOIN ' + @database + '.[INFORMATION_SCHEMA].[TABLE_CONSTRAINTS] B '
+ 'ON A.CONSTRAINT_NAME = B.CONSTRAINT_NAME '
+ 'WHERE B.CONSTRAINT_TYPE IN ( ''PRIMARY KEY'',''UNIQUE'') '

EXECUTE(@sqltext)

SET @sqltext = 'INSERT INTO [DBA].[dbo].[Constraints] ([tableschema], [tablecatalog], [tablename],[columnname], [constrainttype], [referencestable], [referencescolumn]) '
+ 'SELECT  A.TABLE_SCHEMA, A.TABLE_CATALOG, A.TABLE_NAME, A.COLUMN_NAME, D.CONSTRAINT_TYPE, C.TABLE_NAME, C.COLUMN_NAME '
+ 'FROM  ' + @database + '.[INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE] A INNER JOIN ' + @database + '.[INFORMATION_SCHEMA].[REFERENTIAL_CONSTRAINTS] B '
+ '      ON A.CONSTRAINT_NAME = B.CONSTRAINT_NAME '
+ 'INNER JOIN ' + @database + '.[INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE] C ON B.UNIQUE_CONSTRAINT_NAME = C.CONSTRAINT_NAME '
+ 'INNER JOIN ' + @database + '.[INFORMATION_SCHEMA].[TABLE_CONSTRAINTS] D ON A.CONSTRAINT_NAME = D.CONSTRAINT_NAME '

EXECUTE(@sqltext)

SET @sqltext = 'INSERT INTO [DBA].[dbo].[Constraints] ([tableschema], [tablecatalog], [tablename],[columnname], [constrainttype], [checkclause]) '
+ 'SELECT A.[TABLE_SCHEMA], A.[TABLE_CATALOG], A.[TABLE_NAME],A.[COLUMN_NAME], B.CONSTRAINT_TYPE, C.CHECK_CLAUSE '
+ 'FROM ' + @database + '.[INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE] A INNER JOIN ' + @database + '.[INFORMATION_SCHEMA].[TABLE_CONSTRAINTS] B '
+ '      ON A.CONSTRAINT_NAME = B.CONSTRAINT_NAME '
+ 'INNER JOIN ' + @database + '.[INFORMATION_SCHEMA].[CHECK_CONSTRAINTS] C ON A.CONSTRAINT_NAME = C.CONSTRAINT_NAME '

EXECUTE(@sqltext)

-- now update Constraints to reflect KEY roles
-- ID - artificial key, column not referenced in any FOREIGN KEY
-- U  - unique key, either UNIQUE or PRIMARY KEY referenced by at least one FOREIGN KEY
-- L  - lookup key, artificial key added to make database querying more efficient
-- FK - proper FOREIGN KEY
UPDATE  a
SET a.constraintrole = 'ID'
FROM [DBA].[dbo].[Constraints] a
WHERE a.constrainttype = 'PRIMARY KEY'
AND NOT EXISTS (SELECT * FROM [DBA].[dbo].Constraints x WHERE x.constrainttype = 'FOREIGN KEY'
                AND x.referencestable = a.tablename AND x.referencescolumn = a.columnname)

UPDATE  a
SET a.constraintrole = 'U'
FROM [DBA].[dbo].[Constraints] a
WHERE a.constrainttype = 'PRIMARY KEY'
AND EXISTS (SELECT * FROM [DBA].[dbo].Constraints x WHERE x.constrainttype = 'FOREIGN KEY'
                AND x.referencestable = a.tablename AND x.referencescolumn = a.columnname)

UPDATE [DBA].[dbo].[Constraints]
SET constraintrole = 'U'
WHERE constrainttype = 'UNIQUE'

UPDATE  a
SET a.constraintrole = 'L'
FROM [DBA].[dbo].[Constraints] a
WHERE a.constrainttype = 'FOREIGN KEY'
AND EXISTS (SELECT * FROM [DBA].[dbo].Constraints x WHERE x.constrainttype = 'FOREIGN KEY'
                AND x.tablename = a.tablename AND x.columnname <> a.columnname
				AND EXISTS (SELECT * FROM [DBA].[dbo].Constraints y
				WHERE y.constrainttype = 'FOREIGN KEY'
				AND y.tablename = x.referencestable
				AND y.referencestable = a.referencestable
				AND y.referencescolumn = a.referencescolumn))

UPDATE  a
SET a.constraintrole = 'FK'
FROM [DBA].[dbo].[Constraints] a
WHERE a.constrainttype = 'FOREIGN KEY'
AND NOT EXISTS (SELECT * FROM [DBA].[dbo].Constraints x WHERE x.constrainttype = 'FOREIGN KEY'
                AND x.tablename = a.tablename AND x.columnname <> a.columnname
				AND EXISTS (SELECT * FROM [DBA].[dbo].Constraints y
				WHERE y.constrainttype = 'FOREIGN KEY'
				AND y.tablename = x.referencestable
				AND y.referencestable = a.referencestable
				AND y.referencescolumn = a.referencescolumn))


-- now update cardinalities

DECLARE @tablename varchar(128), @columnname varchar(128), @reftable varchar(128), @refcolumn varchar(128)
DECLARE @fkcount int, @refkcount int
DECLARE @tablecardinality varchar(5), @refcardinality varchar(5)

DECLARE csr CURSOR LOCAL FAST_FORWARD FOR
SELECT tablename, columnname, referencestable, referencescolumn
FROM [DBA].[dbo].[Constraints]
WHERE constrainttype = 'FOREIGN KEY' and constraintrole = 'FK'


OPEN csr
FETCH csr INTO @tablename, @columnname, @reftable, @refcolumn
WHILE @@FETCH_STATUS = 0
BEGIN

   SET @sqltext = 'SELECT @fk = COUNT(DISTINCT [' + @columnname + ']) FROM [' + @database + ']..[' + @tablename + ']'
   EXEC sp_executesql @sqltext, N'@fk int out', @fkcount out
   SET @sqltext = 'SELECT @fk = COUNT(DISTINCT [' + @refcolumn + ']) FROM [' + @database + ']..[' + @reftable + ']'
   EXEC sp_executesql @sqltext, N'@fk int out', @refkcount out

   IF @fkcount = @refkcount SET @tablecardinality = '1..1' ELSE SET @tablecardinality = '0..1'

   SET @sqltext = ';WITH cardinality (tablekey, counter) AS ('
                + 'SELECT [' + @database + ']..[' + @tablename + '].[' + @columnname + '], COUNT([' + @database + ']..[' + @reftable + '].[' + @refcolumn + ']) '
                + 'FROM [' + @database + ']..[' + @tablename + '] LEFT OUTER JOIN [' +@database + ']..[' + @reftable +'] ON '
				+ '[' + @tablename + '].[' + @columnname + '] = [' + @reftable + '].[' + @refcolumn + '] '
				+ ' GROUP BY [' + @tablename + '].[' + @columnname + '] ) '
                + ' SELECT @c = CASE WHEN min(counter) > 0 THEN ''1'' ELSE ''0'' END  + ''..'' + CASE WHEN max(counter) > 1 THEN ''*'' ELSE CAST(max(counter) as varchar) END from cardinality'

   EXEC sp_executesql @sqltext, N'@c varchar(5) out', @refcardinality out

   SET @sqltext = 'UPDATE [DBA].[dbo].[Constraints] SET [table:ref] = ''' + @tablecardinality + ''''
                + ', [ref:table] = ''' + @refcardinality + ''''
				+ ' WHERE tablename = ''' + @tablename + ''' AND columnname = ''' + @columnname + ''''
				+ ' AND referencestable = ''' + @reftable + ''' AND referencescolumn = ''' + @refcolumn + ''''
   EXECUTE(@sqltext)


   FETCH csr INTO @tablename, @columnname, @reftable, @refcolumn
END

CLOSE csr
DEALLOCATE csr



-- now start populating the data quality
DECLARE csr CURSOR LOCAL FAST_FORWARD FOR
SELECT [tableschema],[tablename] FROM [DBA].[dbo].[TableStats]

DECLARE @tableschema varchar(128)
DECLARE @tablerows int

OPEN csr
FETCH csr INTO @tableschema, @tablename
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @sqltext = 'SELECT @rc = COUNT(*) From [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
  EXEC sp_executesql @sqltext, N'@rc int out', @tablerows out

	SET @sqltext = 'UPDATE [DBA].[dbo].[TableStats] SET [05_rowcount] = ' + CAST(@tablerows as varchar) + ' WHERE [tablename] = ''' + @tablename + ''''
	EXECUTE(@sqltext)

	SET @sqltext = 'UPDATE [DBA].[dbo].[ColumnStats] SET [05_rowcount] = ' + CAST(@tablerows as varchar) + ' WHERE [tableschema] = ''' + @tableschema + ''''
	+ ' AND [tablename] = ''' + @tablename + ''''
	EXECUTE(@sqltext)

	DECLARE @cols INT
	SET @sqltext = 'SELECT @cols=COUNT(*) FROM [DBA].[dbo].[ColumnStats] WHERE ([datatype] = ''datetime'' OR [datatype] = ''datetime2'') AND [tablename] = ''' + @tablename + ''''
	EXEC sp_executesql @sqltext, N'@cols int out', @cols out
	IF @cols is NULL
		SET @cols = 0

	SET @sqltext = 'UPDATE [DBA].[dbo].[TableStats] SET [timestampcols] = ' + CAST(@cols as varchar) + ' WHERE [tablename] = ''' + @tablename + ''''
	EXECUTE(@sqltext)

  FETCH csr INTO @tableschema, @tablename
END

CLOSE csr
DEALLOCATE csr


DECLARE @datatype varchar(128)
DECLARE @rowcount float, @emptyrows float,@missing float, @distinctvalues float, @distinctvalues_ratio varchar(255), @divers varchar(255)
DECLARE @avgvalue varchar(255), @stddev varchar(255), @mode varchar(255)
DECLARE @minvalue varchar(255), @maxvalue varchar(255)
DECLARE @minlength varchar(255), @maxlength varchar(255), @avglength varchar(255)
DECLARE @minprec varchar(255), @maxprec varchar(255), @avgprec varchar(255)
DECLARE @minprec_time varchar(255), @maxprec_time varchar(255), @avgprec_time varchar(255)
DECLARE @time_entry_usage varchar(255), @duplicates varchar(255), @duplicates_ratio varchar(255), @patterncount float, @anonymity varchar(255)
DECLARE @distance varchar(255), @a varchar(255), @b varchar(255), @outliers varchar(255), @outliers_ratio varchar(255)
DECLARE @typecastable varchar(255), @typecastable_ratio varchar(255)
DECLARE @predefined varchar(255), @predef_min float, @predef_max float, @predef_set NVARCHAR(4000)
DECLARE @distinct_IDs varchar(255), @dk_ids int, @dk_ids_ratio float

DECLARE csr CURSOR LOCAL FAST_FORWARD FOR
SELECT [tableschema], [tablename], [columnname], [datatype]
FROM [DBA].[dbo].[ColumnStats]

OPEN csr
FETCH csr INTO @tableschema, @tablename, @columnname, @datatype
WHILE @@FETCH_STATUS = 0
BEGIN

	-- 17: missing values
	SET @sqltext = 'SELECT @rc = COUNT(*) From [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
	EXEC sp_executesql @sqltext, N'@rc float out', @rowcount out
	SET @sqltext = 'SELECT @er = COUNT(*) From [' + @database + '].[' + @tableschema + '].[' + @tablename + '] WHERE [' + @columnname + '] IS NULL'
	EXEC sp_executesql @sqltext, N'@er float out', @emptyrows out
	IF @rowcount = 0
	  SET @missing = 100
	ELSE
	  SET @missing = @emptyrows/@rowcount * 100

	-- 10: avg length of strings
	IF @datatype = 'varchar' or @datatype = 'nvarchar' or @datatype = 'char'
		BEGIN
			SET @sqltext = 'SELECT @avglength = avg(cast(len([' + @columnname + ']) as float)) From [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@avglength varchar(255) out', @avglength out
			IF @avglength is NULL
				SET @avglength = '0'
			IF @missing = 100
				SET @avglength = 'NULL'
		END
	ELSE
		BEGIN
			SET @avglength = 'NULL'
		END

	-- 19: anonymity (more patterns to be added later)
	IF @missing = 1 OR @rowcount = 0
	  SET @anonymity = '100'
	ELSE
		BEGIN
			SET @sqltext = 'SELECT @pc = COUNT(*) From [' + @database + '].[' + @tableschema + '].[' + @tablename + '] ' +
								 'WHERE [' + @columnname + '] IS NOT NULL AND (' +
										   '[' + @columnname + '] LIKE ''%Mr%'' COLLATE Latin1_General_BIN OR' +
								 			 '[' + @columnname + '] LIKE ''%Ms%'' COLLATE Latin1_General_BIN OR' +
											 '[' + @columnname + '] LIKE ''%Dr%'' COLLATE Latin1_General_BIN OR' +
											 '[' + @columnname + '] LIKE ''%male%'' COLLATE Latin1_General_BIN OR' +
											 '[' + @columnname + '] LIKE ''[1-9]%[A-z]%St%'' COLLATE Latin1_General_BIN OR' +
											 '[' + @columnname + '] LIKE ''[1-9]%[A-z]%Rd%'' COLLATE Latin1_General_BIN OR' +
											 '[' + @columnname + '] LIKE ''[0-9][0-9][0-9][0-9]'' COLLATE Latin1_General_BIN)'
			EXEC sp_executesql @sqltext, N'@pc float out', @patterncount out
			SET @anonymity = cast(((1 - @patterncount/@rowcount)*100) as varchar)
		END

	-- 22: number of distinct values
	-- 20: duplicates
	SET @sqltext = 'SELECT @ds = COUNT(DISTINCT [' + @columnname + ']) FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
  EXEC sp_executesql @sqltext, N'@ds float out', @distinctvalues out
	IF @missing = 100
		SET @distinctvalues_ratio = 'NULL'
	ELSE
		SET @distinctvalues_ratio = cast(@distinctvalues / cast(@rowcount as float) as varchar)
	SET @duplicates = cast((@rowcount - @emptyrows - @distinctvalues) as varchar)
	IF @missing = 100
		SET @duplicates_ratio = 'NULL'
	ELSE
		SET @duplicates_ratio = cast(cast(@rowcount - @emptyrows - @distinctvalues as float)/cast(@rowcount-@emptyrows as float) as varchar)

	-- 23: diversity with Shannon entropy
	IF @rowcount <> 0 AND @distinctvalues > 1
		BEGIN
			SET @sqltext = 'SELECT @divers=(-1*sum(co_new) / log(count([' + @columnname + ']),2)) from(' +
               'SELECT [' + @columnname + '], co*log(co,2) as co_new from (' +
               'SELECT [' + @columnname + '], cast(count(1) as float)/(select cast(count([' + @columnname + ']) as float) ' +
               'FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + '] WHERE ['+@columnname+'] IS NOT NULL) as co ' +
               'FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + '] WHERE ['+@columnname+'] IS NOT NULL group by [' + @columnname + ']) u ) v'
			EXEC sp_executesql @sqltext, N'@divers varchar(255) out', @divers out
		END
	ELSE
		SET @divers = 'NULL'

	-- 26: min/max length of strings
	IF @datatype = 'varchar' or @datatype = 'nvarchar' or @datatype = 'char'
		BEGIN
			SET @sqltext = 'SELECT @minlength = min(cast(len([' + @columnname + ']) as float)) From [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@minlength varchar(255) out', @minlength out
			SET @sqltext = 'SELECT @maxlength = max(cast(len([' + @columnname + ']) as float)) From [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@maxlength varchar(255) out', @maxlength out
			IF @minlength is NULL
				SET @minlength = '0'
			IF @maxlength is NULL
				SET @maxlength = '0'
		END
	ELSE
		BEGIN
			SET @minlength = 'NULL'
			SET @maxlength = 'NULL'
		END

	-- 08: average numeric precision
	-- 09: average time precision
	-- 27: min/max precision of numerics / datetime
	IF @datatype = 'int' or @datatype = 'numeric' or @datatype = 'smallint' or @datatype = 'bigint' or @datatype = 'varbinary'
		BEGIN
			IF @missing = 100
				BEGIN
					SET @minprec = 'NULL'
					SET @maxprec = 'NULL'
					SET @avgprec = 'NULL'
				END
			ELSE
				BEGIN
					SET @minprec = '0'
					SET @maxprec = '0'
					SET @avgprec = '0'
				END
			SET @minprec_time = 'NULL'
			SET @maxprec_time = 'NULL'
			SET @avgprec_time = 'NULL'
		END
	IF @datatype = 'float' or @datatype = 'decimal' or @datatype = 'money' or @datatype = 'real'
		BEGIN
			IF @missing = 100
				BEGIN
					SET @minprec = 'NULL'
					SET @maxprec = 'NULL'
					SET @avgprec = 'NULL'
				END
			ELSE
				BEGIN
					SET @sqltext = 'select @maxprec = max(len(cast(cast(reverse(cast(abs(['+@columnname+']) as DECIMAL(30,10))) as float) as bigint))) from [' + @database + '].[' + @tableschema + '].[' + @tablename + '] WHERE ['+@columnname+'] IS NOT NULL'
					EXEC sp_executesql @sqltext, N'@maxprec varchar(255) out', @maxprec out
					SET @sqltext = 'select @minprec = min(len(cast(cast(reverse(cast(abs(['+@columnname+']) as DECIMAL(30,10))) as float) as bigint))) from [' + @database + '].[' + @tableschema + '].[' + @tablename + '] WHERE ['+@columnname+'] IS NOT NULL'
					EXEC sp_executesql @sqltext, N'@minprec varchar(255) out', @minprec out
					SET @sqltext = 'select @avgprec = avg(cast(len(cast(cast(reverse(cast(abs(['+@columnname+']) as DECIMAL(30,10))) as float) as bigint)) as float)) from [' + @database + '].[' + @tableschema + '].[' + @tablename + '] WHERE ['+@columnname+'] IS NOT NULL'
					EXEC sp_executesql @sqltext, N'@avgprec varchar(255) out', @avgprec out
				END

			SET @minprec_time = 'NULL'
			SET @maxprec_time = 'NULL'
			SET @avgprec_time = 'NULL'
		END
	IF @datatype = 'datetime' or @datatype = 'datetime2'
		BEGIN
			SET @minprec = 'NULL'
			SET @maxprec = 'NULL'
			SET @avgprec = 'NULL'

			DECLARE @milli float, @second float, @minute float, @hour float, @day float, @month float
			SET @sqltext = 'select @milli=avg(cast(datepart(millisecond, ['+@columnname+']) as float)) from [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@milli float out', @milli out
			SET @sqltext = 'select @second=avg(cast(datepart(second, ['+@columnname+']) as float)) from [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@second float out', @second out
			SET @sqltext = 'select @minute=avg(cast(datepart(minute, ['+@columnname+']) as float)) from [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@minute float out', @minute out
			SET @sqltext = 'select @hour=avg(cast(datepart(hour, ['+@columnname+']) as float)) from [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@hour float out', @hour out
			SET @sqltext = 'select @day=avg(cast(datepart(day, ['+@columnname+']) as float)) from [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@day float out', @day out
			SET @sqltext = 'select @month=avg(cast(datepart(month, ['+@columnname+']) as float)) from [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@month float out', @month out
			SET @maxprec_time = '''year'''
			IF @month > 0
				SET @maxprec_time = '''month'''
			IF @day > 0
				SET @maxprec_time = '''day'''
			IF @hour > 0
				SET @maxprec_time = '''hour'''
			IF @minute > 0
				SET @maxprec_time = '''minute'''
			IF @second > 0
				SET @maxprec_time = '''second'''
			IF @milli > 0
				SET @maxprec_time = '''milli'''

			SET @sqltext = 'select @milli=min(cast(datepart(millisecond, ['+@columnname+']) as float)) from [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@milli float out', @milli out
			SET @sqltext = 'select @second=min(cast(datepart(second, ['+@columnname+']) as float)) from [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@second float out', @second out
			SET @sqltext = 'select @minute=min(cast(datepart(minute, ['+@columnname+']) as float)) from [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@minute float out', @minute out
			SET @sqltext = 'select @hour=min(cast(datepart(hour, ['+@columnname+']) as float)) from [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@hour float out', @hour out
			SET @sqltext = 'select @day=min(cast(datepart(day, ['+@columnname+']) as float)) from [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@day float out', @day out
			SET @sqltext = 'select @month=min(cast(datepart(month, ['+@columnname+']) as float)) from [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@month float out', @month out
			SET @minprec_time = '''milli'''
			IF @milli = 0
				SET @minprec_time = '''second'''
			IF @second = 0
				SET @minprec_time = '''minute'''
			IF @minute = 0
				SET @minprec_time = '''hour'''
			IF @hour = 0
				SET @minprec_time = '''day'''

			-- var: year     month    day      hour     minute   second   millisecond
			DECLARE @t1 float, @t2 float, @t3 float, @t4 float, @t5 float, @t6 float, @t7 float

			SET @sqltext = 'select @t7=count(*) from [' + @database + '].[' + @tableschema + '].[' + @tablename + '] ' +
										 'WHERE cast(datepart(millisecond, [' + @columnname + ']) as float) > 0'
			EXEC sp_executesql @sqltext, N'@t7 float out', @t7 out

			SET @sqltext = 'select @t6=count(*) from [' + @database + '].[' + @tableschema + '].[' + @tablename + '] ' +
										 'WHERE cast(datepart(second, [' + @columnname + ']) as float) > 0 AND ' +
										 			 'cast(datepart(millisecond, [' + @columnname + ']) as float) = 0'
			EXEC sp_executesql @sqltext, N'@t6 float out', @t6 out

			SET @sqltext = 'select @t5=cast(count(*) as float) from [' + @database + '].[' + @tableschema + '].[' + @tablename + '] ' +
										 'WHERE cast(datepart(minute, [' + @columnname + ']) as float) > 0 AND ' +
										 			 'cast(datepart(second, [' + @columnname + ']) as float) = 0 AND ' +
													 'cast(datepart(millisecond, [' + @columnname + ']) as float) = 0'
			EXEC sp_executesql @sqltext, N'@t5 float out', @t5 out

			SET @sqltext = 'select @t4=count(*) from [' + @database + '].[' + @tableschema + '].[' + @tablename + '] ' +
										 'WHERE cast(datepart(hour, [' + @columnname + ']) as float) > 0 AND ' +
													 'cast(datepart(minute, [' + @columnname + ']) as float) = 0 AND ' +
										 			 'cast(datepart(second, [' + @columnname + ']) as float) = 0 AND ' +
													 'cast(datepart(millisecond, [' + @columnname + ']) as float) = 0'
			EXEC sp_executesql @sqltext, N'@t4 float out', @t4 out

			SET @sqltext = 'select @t3=count(*) from [' + @database + '].[' + @tableschema + '].[' + @tablename + '] ' +
										 'WHERE cast(datepart(day, [' + @columnname + ']) as float) > 0 AND ' +
													 'cast(datepart(hour, [' + @columnname + ']) as float) = 0 AND ' +
													 'cast(datepart(minute, [' + @columnname + ']) as float) = 0 AND ' +
										 			 'cast(datepart(second, [' + @columnname + ']) as float) = 0 AND ' +
													 'cast(datepart(millisecond, [' + @columnname + ']) as float) = 0'
			EXEC sp_executesql @sqltext, N'@t3 float out', @t3 out

			SET @sqltext = 'select @t2=count(*) from [' + @database + '].[' + @tableschema + '].[' + @tablename + '] ' +
										 'WHERE cast(datepart(month, [' + @columnname + ']) as float) > 0 AND ' +
													 'cast(datepart(day, [' + @columnname + ']) as float) = 0 AND ' +
													 'cast(datepart(hour, [' + @columnname + ']) as float) = 0 AND ' +
													 'cast(datepart(minute, [' + @columnname + ']) as float) = 0 AND ' +
										 			 'cast(datepart(second, [' + @columnname + ']) as float) = 0 AND ' +
													 'cast(datepart(millisecond, [' + @columnname + ']) as float) = 0'
			EXEC sp_executesql @sqltext, N'@t2 float out', @t2 out

			SET @sqltext = 'select @t1=count(*) from [' + @database + '].[' + @tableschema + '].[' + @tablename + '] ' +
										 'WHERE cast(datepart(year, [' + @columnname + ']) as float) > 0 AND ' +
													 'cast(datepart(month, [' + @columnname + ']) as float) = 0 AND ' +
													 'cast(datepart(day, [' + @columnname + ']) as float) = 0 AND ' +
													 'cast(datepart(hour, [' + @columnname + ']) as float) = 0 AND ' +
													 'cast(datepart(minute, [' + @columnname + ']) as float) = 0 AND ' +
										 			 'cast(datepart(second, [' + @columnname + ']) as float) = 0 AND ' +
													 'cast(datepart(millisecond, [' + @columnname + ']) as float) = 0'
			EXEC sp_executesql @sqltext, N'@t1 float out', @t1 out

			DECLARE @fc FLOAT
			SET @fc = 1.0/6.0

			IF @missing = 100
				BEGIN
					SET @minprec_time = 'NULL'
					SET @maxprec_time = 'NULL'
					SET @avgprec_time = 'NULL'
				END
			ELSE
				BEGIN
					SET @avgprec_time = cast((0*@fc*@t1 + 1*@fc*@t2 + 2*@fc*@t3 + 3*@fc*@t4 + 4*@fc*@t5 + 5*@fc*@t6 + 6*@fc*@t7) / (@t1+@t2+@t3+@t4+@t5+@t6+@t7) as varchar)
				END
		END
	IF @datatype = 'varchar' or @datatype = 'nvarchar' or @datatype = 'char'
		BEGIN
			SET @minprec = 'NULL'
			SET @maxprec = 'NULL'
			SET @avgprec = 'NULL'
			SET @minprec_time = 'NULL'
			SET @maxprec_time = 'NULL'
			SET @avgprec_time = 'NULL'
		END

	-- 28: now get min & max values
	IF @missing = 100
		BEGIN
			SET @minvalue = 'NULL'
			SET @maxvalue = 'NULL'
		END
	ELSE
		BEGIN
			SET @sqltext = 'SELECT @min = CAST( MIN([' + @columnname + ']) as varchar) FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@min varchar(255) out', @minvalue out

			SET @sqltext = 'SELECT @max = CAST( MAX([' + @columnname + ']) as varchar) FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@max varchar(255) out', @maxvalue out
			SET @minvalue = replace(@minvalue, '''', '')
			SET @maxvalue = replace(@maxvalue, '''', '')
			SET @minvalue = '''' + @minvalue + ''''
			SET @maxvalue = '''' + @maxvalue + ''''
		END

	-- 06: outliers (more than x=2 SD away from the mean)
	-- 25: time between data entry & usage
	-- 29: average value only for float, int
	-- 30: std deviation only for float, int
	DECLARE @over varchar(255), @under varchar(255)
	DECLARE @avg1 float, @std1 float
	IF @datatype = 'float' or @datatype = 'decimal' or @datatype = 'money' or @datatype = 'real' or @datatype = 'int' or @datatype = 'numeric' or @datatype = 'smallint' or @datatype = 'bigint'
		BEGIN
			SET @sqltext = 'SELECT @avg = cast(AVG(cast([' + @columnname + '] as float)) as varchar) FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@avg varchar(255) out', @avgvalue out
			SET @sqltext = 'SELECT @std = cast(STDEV(cast([' + @columnname + '] as float)) as varchar) FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
			EXEC sp_executesql @sqltext, N'@std varchar(255) out', @stddev out
			IF @avgvalue IS NULL
				BEGIN
					SET @avgvalue = 'NULL'
					SET @stddev = 'NULL'
					SET @outliers = '0'
					SET @outliers_ratio = '0'
				END
			ELSE
				BEGIN
					SET @avg1 = cast(@avgvalue as float)
					SET @std1 = cast(@stddev as float)
					SET @over = cast((@avg1 + 2*@std1) as varchar)
					SET @under = cast((@avg1 - 2*@std1) as varchar)
					SET @sqltext = 'SELECT @out = COUNT([' + @columnname + ']) FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + '] ' +
										 		 'WHERE [' + @columnname + '] > ' + @over + ' OR [' + @columnname + '] < ' + @under
					EXEC sp_executesql @sqltext, N'@out varchar(255) out', @outliers out
					IF @outliers IS NULL
						BEGIN
							SET @outliers = '0'
							SET @outliers_ratio = '0'
						END
					ELSE
						BEGIN
							SET @outliers_ratio = cast(cast(@outliers as float)/cast(@rowcount as float) as varchar)
						END
					SET @avgvalue = '''' + @avgvalue + ''''
					SET @stddev = '''' + @stddev + ''''
				END
			SET @time_entry_usage = 'NULL'
		END
	ELSE
		BEGIN
			IF @datatype = 'datetime2' or @datatype = 'datetime'
				BEGIN
					SET @sqltext = 'SELECT @avg = cast(cast(AVG(cast(cast([' + @columnname + '] as datetime) as float)) as datetime) as varchar) FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
					EXEC sp_executesql @sqltext, N'@avg varchar(255) out', @avgvalue out
					SET @sqltext = 'SELECT @std = cast(cast(STDEV(cast(cast([' + @columnname + '] as datetime) as float)) as datetime) as varchar) FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + ']'
					EXEC sp_executesql @sqltext, N'@std varchar(255) out', @stddev out

					IF @avgvalue IS NULL
						BEGIN
							SET @time_entry_usage = 'NULL'
							SET @avgvalue = 'NULL'
							SET @stddev = 'NULL'
              SET @outliers = '0'
							SET @outliers_ratio = '0'
						END
					ELSE
						BEGIN
							SET @time_entry_usage = DATEDIFF(DAY, cast(@avgvalue as datetime), SYSDATETIME())

							SET @avg1 = cast(cast(@avgvalue as datetime) as float)
							SET @std1 = cast(cast(@stddev as datetime) as float)
							SET @over = cast((@avg1 + 2*@std1) as varchar)
							SET @under = cast((@avg1 - 2*@std1) as varchar)
							SET @sqltext = 'SELECT @out = COUNT([' + @columnname + ']) FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + '] ' +
										 				 'WHERE cast([' + @columnname + '] as float) > ' + @over + ' OR cast([' + @columnname + '] as float) < ' + @under
							EXEC sp_executesql @sqltext, N'@out varchar(255) out', @outliers out
							IF @outliers IS NULL
								BEGIN
									SET @outliers = '0'
									SET @outliers_ratio = '0'
								END
							ELSE
								BEGIN
									SET @outliers_ratio = cast(cast(@outliers as float)/cast(@rowcount as float) as varchar)
								END
							SET @avgvalue = '''' + @avgvalue + ''''
							SET @stddev = '''' + @stddev + ''''
						END
				END
			ELSE
				BEGIN
					SET @time_entry_usage = 'NULL'
					SET @avgvalue = 'NULL'
					SET @stddev = 'NULL'
					SET @outliers = 'NULL'
					SET @outliers_ratio = 'NULL'
				END
		END

	-- 31: mode (for all data types)
	SET @sqltext = 'SELECT @mode = cast([' + @columnname + '] as varchar) from (select top 1 ([' + @columnname + ']), count(1) as co ' +
								 'from [' + @database + '].[' + @tableschema + '].[' + @tablename + '] group by [' + @columnname + '] order by co DESC) t'
	EXEC sp_executesql @sqltext, N'@mode varchar(255) out', @mode out
	IF @mode IS NULL
			SET @mode = 'NULL'
	ELSE
		BEGIN
			IF @missing = 100
				SET @mode = 'NULL'
			ELSE
				BEGIN
					SET @mode = replace(@mode, '''', '')
					SET @mode = '''' + @mode + ''''
				END
		END

	-- 11: similar values (with Levenshtein distance)
	-- currently, only columns with 100 or less distinct values are addressed as this metric requires a lot of computing time
	SET @sqltext = 'SELECT @ld = dis, @a=l, @b=r FROM (SELECT top 1 dis = ' + @df + '(a.[' + @columnname + '], b.[' + @columnname + ']), l=a.[' + @columnname + '], r=b.[' + @columnname + '] ' +
								 'FROM (SELECT DISTINCT([' + @columnname + ']) FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + ']) a CROSS JOIN (SELECT DISTINCT([' + @columnname + ']) FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + ']) b ' +
								 'WHERE a.[' + @columnname + '] <> b.[' + @columnname + '] AND a.[' + @columnname + '] IS NOT NULL AND b.[' + @columnname + '] IS NOT NULL ORDER BY dis ASC) d'
	IF @distinctvalues < 100
		BEGIN
			EXEC sp_executesql @sqltext, N'@ld varchar(255) output, @a varchar(255) output, @b varchar(255) output', @distance out, @a out, @b out
			IF @distance IS NULL OR @a IS NULL OR @b IS NULL
				BEGIN
					SET @distance = 'NULL'
					SET @a = 'NULL'
					SET @b = 'NULL'
				END
      		ELSE
        			BEGIN
	        			SET @a = replace(@a, '''', '')
	        			SET @b = replace(@b, '''', '')
          			SET @a = '''' + @a + ''''
					SET @b = '''' + @b + ''''
        			END
		END
	ELSE
		BEGIN
			SET @distance = 'NULL'
			SET @a = 'NULL'
			SET @b = 'NULL'
		END

	-- 07: type-castable strings
	IF @datatype = 'varchar' or @datatype = 'nvarchar' or @datatype = 'char'
		BEGIN
			IF @missing = 100
				BEGIN
					SET @typecastable = '0'
					SET @typecastable_ratio = '0'
				END
			ELSE
				BEGIN
					SET @sqltext = 'SELECT @cast = count(*) from [' + @database + '].[' + @tableschema + '].[' + @tablename + '] WHERE TRY_CAST([' + @columnname + '] AS FLOAT) IS NOT NULL'
					EXEC sp_executesql @sqltext, N'@cast varchar(255) out', @typecastable out
					SET @typecastable_ratio = cast(cast(@typecastable as float) / cast(@rowcount as float) as varchar)
				END
		END
	ELSE
		BEGIN
			SET @typecastable = 'NULL'
			SET @typecastable_ratio = 'NULL'
		END

	-- 02: within predefined value-set?
  IF @datatype = 'float' or @datatype = 'decimal' or @datatype = 'money' or @datatype = 'real' or @datatype = 'int' or
     @datatype = 'numeric' or @datatype = 'smallint' or @datatype = 'bigint' or @datatype = 'varbinary' or
     @datatype = 'datetime' or @datatype = 'datetime2'
		BEGIN
      SELECT @predef_max=[max_value], @predef_min=[min_value] FROM [DBA].[dbo].DomainKnowledge
      WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
      IF @missing = 100 OR @predef_max IS NULL OR @predef_min IS NULL
        BEGIN
          SET @predefined = '1'
        END
      ELSE
        BEGIN
          SET @sqltext = 'SELECT @pre = COUNT([' + @columnname + ']) FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + '] ' +
										 				 'WHERE cast([' + @columnname + '] as float) > ' + cast(@predef_max as varchar) + ' OR cast([' + @columnname + '] as float) < ' + cast(@predef_min as varchar)
					EXEC sp_executesql @sqltext, N'@pre varchar(255) out', @predefined out
          SET @predefined = cast(1 - cast(@predefined as float) / @rowcount as varchar)
        END
    END
  ELSE
    BEGIN
      IF @datatype = 'varchar' or @datatype = 'nvarchar' or @datatype = 'char'
        BEGIN
          SELECT @predef_set=[categories] FROM [DBA].[dbo].DomainKnowledge
          WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
          IF @missing = 100 OR @predef_set IS NULL
            BEGIN
              SET @predefined = '1'
            END
          ELSE
            BEGIN
              SET @sqltext = 'SELECT @pre = COUNT([' + @columnname + ']) FROM [' + @database + '].[' + @tableschema + '].[' + @tablename + '] ' +
										 				 'WHERE [' + @columnname + '] NOT IN (SELECT value FROM STRING_SPLIT('''+@predef_set+''', '';''))'
					    EXEC sp_executesql @sqltext, N'@pre varchar(255) out', @predefined out
              SET @predefined = cast(1 - cast(@predefined as float) / @rowcount as varchar)
            END
        END
      ELSE
        BEGIN
          SET @predefined = 'NULL'
        END
    END

    -- 21: distinct IDs (more or less than real world?!)
    SELECT @dk_ids = [distinct_values] FROM [DBA].[dbo].DomainKnowledge 
    WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
    IF @dk_ids IS NULL
    	BEGIN
	    SET	@distinct_IDs = 'NULL'
    	END 
	ELSE
	BEGIN
		IF @distinctvalues <= @dk_ids
		BEGIN
			SET @dk_ids_ratio = @distinctvalues / cast(@dk_ids as float)
		END 
		ELSE
		BEGIN
			SET @dk_ids_ratio = cast(@dk_ids as float) / @distinctvalues
		END 
		SET @distinct_IDs = cast(@dk_ids_ratio as varchar)
	END 
	
	
	-- save values
	SET @sqltext = 'UPDATE [DBA].[dbo].[ColumnStats] '
	+ 'SET [02_predefined_value] =' + @predefined
  	+ ', [06_outliers] = ' + @outliers
	+ ', [06_outliers_ratio] = ' + @outliers_ratio
	+ ', [07_typecastable] = ' + @typecastable
	+ ', [07_typecastable_ratio] = ' + @typecastable_ratio
	+ ', [08_numeric_precision] = ' + @avgprec
	+ ', [09_time_precision] = ' + @avgprec_time
	+ ', [10_avg_length_strings] = ' + @avglength
	+ ', [11_similarity] = ' + @distance
  	+ ', [11_similarity_left] = ' + @a
  	+ ', [11_similarity_right] = ' + @b
	+ ', [17_missing] = ' + CAST(@missing as varchar)
	+ ', [19_anonymity] = ' + @anonymity
	+ ', [20_duplicates] = ' + @duplicates
	+ ', [20_duplicates_ratio] = ' + @duplicates_ratio
	+ ', [21_distinct_IDs] = ' + @distinct_IDs
	+ ', [22_richness] = ' + CAST(@distinctvalues as varchar)
	+ ', [22_richness_ratio] = ' + @distinctvalues_ratio
	+ ', [23_diversity] = ' + @divers
	+ ', [25_time_entry_usage] = ' + @time_entry_usage
	+ ', [26_min_length_strings] = ' + @minlength
	+ ', [26_max_length_strings] = ' + @maxlength
	+	', [27_min_precision] = ' + @minprec
	+ ', [27_max_precision] = ' + @maxprec
	+	', [27_min_precision_time] = ' + @minprec_time
	+ ', [27_max_precision_time] = ' + @maxprec_time
	+ ', [28_min_value] = ' + @minvalue
	+ ', [28_max_value] = ' + @maxvalue
	+ ', [29_avg_value] = ' + @avgvalue
	+ ', [30_std_deviation] = ' + @stddev
	+ ', [31_mode] = ' + @mode
	+ ' WHERE [tablecatalog] = ''' + @database + ''''
	+ ' AND [tableschema] = ''' + @tableschema + ''''
	+ ' AND [tablename] = ''' + @tablename + ''''
	+ ' AND [columnname] = ''' + @columnname + ''''
	EXECUTE(@sqltext)

 	-- now get another row from the cursor
	FETCH csr INTO @tableschema, @tablename, @columnname, @datatype
END

CLOSE csr
DEALLOCATE csr

RETURN 0

END
