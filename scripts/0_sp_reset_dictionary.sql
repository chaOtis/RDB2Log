CREATE procedure [dbo].[sp_reset_dictionary]
@database varchar(128) = NULL

AS
BEGIN

IF @database IS NULL
	SET @database = db_name()

DECLARE @sqltext nvarchar(4000)

DROP TABLE [DBA].[dbo].[TableStats]

DROP TABLE [DBA].[dbo].[ColumnStats]

DROP TABLE [DBA].[dbo].[Constraints]

DROP TABLE [DBA].[dbo].[ColumnQuality]

DROP TABLE [DBA].[dbo].[ColumnRoles]

DROP TABLE [DBA].[dbo].[DomainKnowledge]

DROP TABLE [DBA].[dbo].[RoleConditions]


CREATE TABLE [DBA].[dbo].[ColumnStats](
	[tablecatalog] [varchar](128) NULL,
	[tableschema] [varchar](128) NULL,
	[tablename] [varchar](128) NULL,
	[columnname] [varchar](128) NULL,
 	[05_rowcount] [int] NULL,
	[datatype] [varchar](128) NULL,
	[maxlength] [int] NULL,
	[numericprecision] [int] NULL,
	[dateprecision] [int] NULL,
	[isnullable] [varchar](50) NULL,
	[description] [nvarchar](4000) NULL,
  	[01_real_world] [float] NULL,
  	[02_predefined_value] [float] NULL,
  	[06_outliers] [float] NULL,
  	[06_outliers_ratio] [float] NULL,
  	[07_typecastable] [float] NULL,
  	[07_typecastable_ratio] [float] NULL,
  	[08_numeric_precision] [float] NULL,
	[09_time_precision] [float] NULL,
  [10_avg_length_strings] [float] NULL,
  [11_similarity] [float] NULL,
  [11_similarity_left] [varchar](255) NULL,
  [11_similarity_right] [varchar](255) NULL,
  [12_formatting] [float] NULL,
  [13_type] [float] NULL,
  [15_ambiguity] [float] NULL,
  [16_constraints][float] NULL,
  [17_missing] [float] NULL,            --renamed from pcnt_missing
  [18_bias] [float] NULL,
  [19_anonymity] [float] NULL,
  [20_duplicates] [float] NULL,
  [20_duplicates_ratio] [float] NULL,
  [21_distinct_IDs] [float] NULL,
  [22_richness] [float] NULL,           --renamed from distinct
  [22_richness_ratio] [float] NULL,           --renamed from distinct
  [23_diversity] [float] NULL,
  [24_time_occur_entry] [int] NULL,     --DATEDIFF returns int
  [25_time_entry_usage] [int] NULL,     --DATEDIFF returns int
  [26_min_length_strings] [float] NULL,
  [26_max_length_strings] [float] NULL,
  [27_min_precision] [int] NULL,
  [27_max_precision] [int] NULL,
  [27_min_precision_time] [varchar](255) NULL,
  [27_max_precision_time] [varchar](255) NULL,
  [28_min_value] [varchar](255) NULL,   --renamed from min
	[28_max_value] [varchar](255) NULL,   --renamed from max
  [29_avg_value] [varchar](255) NULL,
  [30_std_deviation] [varchar](255) NULL,
  [31_mode] [varchar](255) NULL
) ON [PRIMARY]

CREATE TABLE [DBA].[dbo].[Constraints](
	[tablecatalog] [varchar](128) NULL,
	[tableschema] [varchar](128) NULL,
	[tablename] [varchar](128) NULL,
	[columnname] [varchar](128) NULL,
	[constrainttype] [varchar](128) NULL,
	[referencestable] [varchar](128) NULL,
	[referencescolumn] [varchar](128) NULL,
	[checkclause] [varchar](128) NULL,
	[description] [nvarchar](4000) NULL,
	[constraintrole] [varchar](5) NULL,
	[table:ref] [varchar](5) NULL,
	[ref:table] [varchar](5) NULL
) ON [PRIMARY]

--rework structure, is not current
CREATE TABLE [DBA].[dbo].[ColumnQuality](
	[tablecatalog] [varchar](128) NULL,
	[tableschema] [varchar](128) NULL,
	[tablename] [varchar](128) NULL,
	[columnname] [varchar](128) NULL,
  [datatype] [varchar](128) NULL,
  [accuracy] [float] NULL,
  [sufficiency] [float] NULL,
  [precision] [float] NULL,
  [consistency] [float] NULL,
  [completeness] [float] NULL,
  [objectivity] [float] NULL,
  [security] [float] NULL,
  [uniqueness] [float] NULL,
  [informativeness] [float] NULL,
  [integrity] [float] NULL,
  [conciseness] [float] NULL,
  [currency] [float] NULL,
) ON [PRIMARY]

CREATE TABLE [DBA].[dbo].[ColumnRoles](
	[tablecatalog] [varchar](128) NULL,
	[tableschema] [varchar](128) NULL,
	[tablename] [varchar](128) NULL,
	[columnname] [varchar](128) NULL,
  [datatype] [varchar](128) NULL,
  [caseID] [float] NULL,
  [activity] [float] NULL,
  [timestamp] [float] NULL,
  [event] [float] NULL,
  [resource] [float] NULL,
  [caseData] [float] NULL,
  [eventData] [float] NULL
) ON [PRIMARY]

CREATE TABLE [DBA].[dbo].[RoleConditions](
  [role] [varchar](128) NULL,
  [accuracy_upper] [float] NULL,
  [accuracy_lower] [float] NULL,
  [sufficiency_upper] [float] NULL,
  [sufficiency_lower] [float] NULL,
  [precision_upper] [float] NULL,
  [precision_lower] [float] NULL,
  [consistency_upper] [float] NULL,
  [consistency_lower] [float] NULL,
  [completeness_upper] [float] NULL,
  [completeness_lower] [float] NULL,
  [objectivity_upper] [float] NULL,
  [objectivity_lower] [float] NULL,
  [security_upper] [float] NULL,
  [security_lower] [float] NULL,
  [uniqueness_upper] [float] NULL,
  [uniqueness_lower] [float] NULL,
  [informativeness_upper] [float] NULL,
  [informativeness_lower] [float] NULL,
  [integrity_upper] [float] NULL,
  [integrity_lower] [float] NULL,
  [conciseness_upper] [float] NULL,
  [conciseness_lower] [float] NULL,
  [currency_upper] [float] NULL,
  [currency_lower] [float] NULL,
)

CREATE TABLE [DBA].[dbo].[TableStats](
	[tablecatalog] [varchar](128) NULL,
	[tableschema] [varchar](128) NULL,
	[tablename] [varchar](128) NULL,
	[tabletype] [varchar](10) NULL,
	[05_rowcount] [int] NULL,
	[description] [nvarchar](4000) NULL,
	[timestampcols] [int] NULL
) ON [PRIMARY]

CREATE TABLE [DBA].[dbo].[DomainKnowledge](
	[tablecatalog] [varchar](128) NULL,
	[tableschema] [varchar](128) NULL,
	[tablename] [varchar](128) NULL,
	[columnname] [varchar](128) NULL,
	[description] [nvarchar](4000) NULL,
	[min_value] float NULL,
	[max_value] float NULL,
	[distinct_values] int NULL,
	[categories][varchar](255) NULL,        -- delimited by ';' ???
	[avg_value] [varchar](255) NULL,        -- only for normally distributed sets (think about others?)
	[std_deviation] [varchar](255) NULL,    -- only for normally distributed sets (think about others?)
)

IF object_id(N'DBA..[TableStats]') IS NOT NULL
DELETE FROM [DBA].[dbo].[TableStats]

IF object_id(N'DBA..[ColumnStats]') IS NOT NULL
DELETE FROM [DBA].[dbo].[ColumnStats]

IF object_id(N'DBA..[DomainKnowledge]') IS NOT NULL
DELETE FROM [DBA].[dbo].[DomainKnowledge]

IF object_id(N'DBA..[ColumnQuality]') IS NOT NULL
DELETE FROM [DBA].[dbo].[ColumnQuality]

IF object_id(N'DBA..[ColumnRoles]') IS NOT NULL
DELETE FROM [DBA].[dbo].[ColumnRoles]

-- now populate TableStats
SET @sqltext = 'INSERT INTO [DBA].[dbo].[TableStats]([tablecatalog],[tableschema],[tablename],[tabletype]) '
+ 'SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE '
+ 'FROM ' + @database + '.INFORMATION_SCHEMA.TABLES'

EXECUTE(@sqltext)

-- now populate ColumnStats
SET @sqltext = 'INSERT INTO [DBA].[dbo].[ColumnStats]([tablecatalog],[tableschema],[tablename],[columnname],[datatype],[maxlength],[numericprecision],[dateprecision],[isnullable]) '
+ 'SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, '
+ 'CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, DATETIME_PRECISION, IS_NULLABLE '
+ 'FROM ' + @database + '.INFORMATION_SCHEMA.COLUMNS '

EXECUTE(@sqltext)

-- now populate DomainKnowledge
SET @sqltext = 'INSERT INTO [DBA].[dbo].[DomainKnowledge]([tablecatalog],[tableschema],[tablename],[columnname]) '
+ 'SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME '
+ 'FROM ' + @database + '.INFORMATION_SCHEMA.COLUMNS '

EXECUTE(@sqltext)

-- now populate ColumnQuality
SET @sqltext = 'INSERT INTO [DBA].[dbo].[ColumnQuality]([tablecatalog],[tableschema],[tablename],[columnname],[datatype]) '
+ 'SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE '
+ 'FROM ' + @database + '.INFORMATION_SCHEMA.COLUMNS '

EXECUTE(@sqltext)

-- now populate ColumnRoles
SET @sqltext = 'INSERT INTO [DBA].[dbo].[ColumnRoles]([tablecatalog],[tableschema],[tablename],[columnname],[datatype]) '
+ 'SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE '
+ 'FROM ' + @database + '.INFORMATION_SCHEMA.COLUMNS '

EXECUTE(@sqltext)

RETURN 0
END
