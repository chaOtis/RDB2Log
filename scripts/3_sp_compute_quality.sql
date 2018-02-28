CREATE PROCEDURE [dbo].[sp_compute_quality]
@database1 varchar(128) = NULL

AS

BEGIN

DECLARE @sqltext nvarchar(4000)

DECLARE @database varchar(128), @tableschema varchar(128), @tablename varchar(128), @columnname varchar(128), @datatype varchar(128)

DECLARE @accuracy varchar(255), @sufficiency varchar(255), @precision varchar(255), @consistency varchar(255), @completeness varchar(255), @objectivity varchar(255)
DECLARE @security varchar(255), @uniqueness varchar(255), @informativeness varchar(255), @integrity varchar(255), @conciseness varchar(255), @currency varchar(255)

DECLARE csr CURSOR LOCAL FAST_FORWARD FOR
SELECT [tablecatalog], [tableschema], [tablename], [columnname], [datatype]
FROM [DBA].[dbo].[ColumnStats]

OPEN csr
FETCH csr INTO @database, @tableschema, @tablename, @columnname, @datatype
WHILE @@FETCH_STATUS = 0
BEGIN

	-- accuracy
	DECLARE @outlie FLOAT
	DECLARE @predef FLOAT
  	SELECT @predef = [02_predefined_value] FROM [DBA].[dbo].ColumnStats
	WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
	SELECT @outlie = 1 - [06_outliers_ratio] FROM [DBA].[dbo].ColumnStats
	WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
	IF @predef IS NULL AND @outlie IS NULL
		SET @accuracy = 'NULL'
	IF @predef IS NULL AND @outlie IS NOT NULL
		SET @accuracy = cast(@outlie as varchar)
	IF @predef IS NOT NULL AND @outlie IS NULL
		SET @accuracy = cast(@predef as varchar)
	IF @predef IS NOT NULL AND @outlie IS NOT NULL
		SET @accuracy = cast(0.5*@predef + 0.5*@outlie as varchar)

	-- sufficiency
  	DECLARE @rows int
	SELECT @rows = [05_rowcount] FROM [DBA].[dbo].ColumnStats
	WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
	SELECT @sufficiency =
		CASE
			WHEN @rows < 1 THEN '0' -- timestamp dates are in the future
			WHEN @rows < 10 THEN '0.2'
			WHEN @rows < 100 THEN '0.4'
			WHEN @rows < 1000 THEN '0.6'
			WHEN @rows < 10000 THEN '0.8'
			WHEN @rows IS NULL THEN 'NULL'
			ELSE '1'
		END

	-- precision
	IF @datatype = 'datetime' OR @datatype = 'datetime2'
  	SELECT @precision = [09_time_precision] FROM [DBA].[dbo].ColumnStats
		WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
	IF @datatype = 'int' OR @datatype = 'bigint' OR @datatype = 'smallint' OR @datatype = 'numeric' OR @datatype = 'varbinary'
		SET @precision = 'NULL'
	IF @datatype = 'decimal' OR @datatype = 'real' OR @datatype = 'float'
		BEGIN
			DECLARE @h1 FLOAT
			SELECT @h1 = [08_numeric_precision] FROM [DBA].[dbo].ColumnStats
			WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
			SELECT @precision =
				CASE
					WHEN @h1 < 1 THEN '0' -- timestamp dates are in the future
					WHEN @h1 = 1 THEN '0.2'
					WHEN @h1 < 2 THEN '0.4'
					WHEN @h1 < 3 THEN '0.6'
					WHEN @h1 < 4 THEN '0.8'
					WHEN @h1 IS NULL THEN 'NULL'
					ELSE '1'
				END
		END
	IF @datatype = 'varchar' OR @datatype = 'nvarchar'
		BEGIN
			DECLARE @h2 FLOAT
			SELECT @h2 = [10_avg_length_strings] FROM [DBA].[dbo].ColumnStats
			WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
			SELECT @precision =
				CASE
					WHEN @h2 < 2 THEN '0' -- timestamp dates are in the future
					WHEN @h2 < 4 THEN '0.2'
					WHEN @h2 < 6 THEN '0.4'
					WHEN @h2 < 8 THEN '0.6'
					WHEN @h2 < 10 THEN '0.8'
					WHEN @h2 IS NULL THEN 'NULL'
					ELSE '1'
				END
		END
	IF @datatype = 'char'
		SET @precision = 'NULL'

	-- consistency
	SELECT @consistency = 1 - [07_typecastable_ratio] FROM [DBA].[dbo].ColumnStats
	WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
  --SET @consistency = 'NULL'

	-- completeness
  SELECT @completeness = 1 -([17_missing]/100) FROM [DBA].[dbo].ColumnStats
	WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
	--SET @completeness = 'NULL'

	-- objectivity
	SELECT @objectivity = [21_distinct_IDs] FROM [DBA].[dbo].ColumnStats
	WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
  	--SET @objectivity = 'NULL'

	-- security
  SELECT @security = [19_anonymity]/100 FROM [DBA].[dbo].ColumnStats
	WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
	--SET @security = 'NULL'

	-- uniqueness
	DECLARE @sim FLOAT
	DECLARE @dup FLOAT
  SELECT @sim = [11_similarity] FROM [DBA].[dbo].ColumnStats
	WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
	SELECT @dup = [20_duplicates_ratio] FROM [DBA].[dbo].ColumnStats
	WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
	IF @sim IS NULL AND @dup IS NULL
		SET @uniqueness = 'NULL'
	IF @sim IS NULL AND @dup IS NOT NULL
		SET @uniqueness = cast(1-@dup as varchar)
	IF @sim IS NOT NULL AND @dup IS NULL
		SET @uniqueness = cast(@sim as varchar)
	IF @sim IS NOT NULL AND @dup IS NOT NULL
		SET @uniqueness = cast(0.5*@sim + 0.5*(1-@dup) as varchar)

	-- informativeness
  SELECT @informativeness = cast([23_diversity] as varchar) FROM [DBA].[dbo].ColumnStats
	WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname


	-- integrity
  SET @integrity = '1'

	-- conciseness CHECK THIS
  SELECT @conciseness = cast([11_similarity] as varchar) FROM [DBA].[dbo].ColumnStats
	WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname

	-- currency
	DECLARE @time float
  SELECT @time = [25_time_entry_usage] FROM [DBA].[dbo].ColumnStats
	WHERE tablecatalog = @database AND tableschema = @tableschema AND tablename = @tablename AND columnname = @columnname
	SELECT @currency =
		CASE
			WHEN @datatype <> 'datetime' AND @datatype <> 'datetime2' THEN 'NULL'
			WHEN @time < 0 THEN '0' -- timestamp dates are in the future
			WHEN @time > 10*365 THEN '0'
			WHEN @time > 5*365 THEN '0.2'
			WHEN @time > 2*365 THEN '0.4'
			WHEN @time > 1*365 THEN '0.6'
			WHEN @time > 0.5*365 THEN '0.8'
			ELSE '1'
		END
	--SET @currency = 'NULL'

	IF @accuracy IS NULL
		SET @accuracy = 'NULL'
	IF @sufficiency IS NULL
  		SET @sufficiency = 'NULL'
	IF @precision IS NULL
  		SET @precision = 'NULL'
	IF @consistency IS NULL
  		SET @consistency = 'NULL'
	IF @completeness IS NULL
		SET @completeness = 'NULL'
	IF @objectivity IS NULL
		SET @objectivity = 'NULL'
	IF @security IS NULL
		SET @security = 'NULL'
	IF @uniqueness IS NULL
		SET @uniqueness = 'NULL'
	IF @informativeness IS NULL
		SET @informativeness = 'NULL'
	IF @integrity IS NULL
		SET @integrity = 'NULL'
	IF @conciseness IS NULL
		SET @conciseness = 'NULL'
	IF @currency IS NULL
		SET @currency = 'NULL'


	-- save values
	SET @sqltext = 'UPDATE [DBA].[dbo].[ColumnQuality] '
	+ 'SET  [accuracy] = ' + @accuracy
	+ ', [sufficiency] = ' + @sufficiency
	+ ', [precision] = ' + @precision
	+ ', [consistency] = ' + @consistency
	+ ', [completeness] = ' + @completeness
	+ ', [objectivity] = ' + @objectivity
	+ ', [security] = ' + @security
	+ ', [uniqueness] = ' + @uniqueness
	+ ', [informativeness] = ' + @informativeness
	+ ', [integrity] = ' + @integrity
	+ ', [conciseness] = ' + @conciseness
	+ ', [currency] = ' + @currency
	+ ' WHERE [tablecatalog] = ''' + @database + ''''
	+ ' AND [tableschema] = ''' + @tableschema + ''''
	+ ' AND [tablename] = ''' + @tablename + ''''
	+ ' AND [columnname] = ''' + @columnname + ''''
	EXECUTE(@sqltext)

 	-- now get another row from the cursor
	FETCH csr INTO @database, @tableschema, @tablename, @columnname, @datatype
END

CLOSE csr
DEALLOCATE csr

RETURN 0

END
