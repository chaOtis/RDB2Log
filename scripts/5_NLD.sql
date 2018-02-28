CREATE FUNCTION NLD(@Source nvarchar(4000), @Target nvarchar(4000))
	RETURNS FLOAT
	AS
	/*
	The Levenshtein string distance algorithm was developed by Vladimir Levenshtein in 1965. It tells you the number of edits required to turn one string into another by breaking down string transformation into three basic operations: adding, deleting, and replacing a character. Each operation is assigned a cost of 1. Leaving a character unchanged has a cost of 0.
	This is a translation of 'Fast, memory efficient Levenshtein algorithm' By Sten Hjelmqvist, originally converted to SQL by Arnold Fribble
	http://www.codeproject.com/Articles/13525/Fast-memory-efficient-Levenshtein-algorithm
	*/
	BEGIN
	  Declare  @MaxDistance int
	  Select @MaxDistance=200
	  DECLARE @SourceStringLength int, @TargetStringLength int, @ii int, @jj int, @SourceCharacter nchar, @Cost int, @Cost1 int,
	      -- create two work vectors of integer distances
	    @Current_Row nvarchar(200), @Previous_Row nvarchar(200), @Min_Cost int
	  SELECT @SourceStringLength = LEN(@Source),
	         @TargetStringLength = LEN(@Target),
	         @Previous_Row = '',
	         @jj = 1, @ii = 1,
	         @Cost = 0, @MaxDistance=200
	    -- do the degenerate cases
	    if @Source = @Target return (@Cost);
	    if @SourceStringLength= 0 return 1;
	    if @TargetStringLength= 0 return 1;

	    -- initialize the previous row of distances
	    -- this row is edit distance for an empty source string
	    -- the distance is just the number of characters to delete from the target
	  WHILE @jj <= @TargetStringLength
	    SELECT @Previous_Row = @Previous_Row + NCHAR(@jj), @jj = @jj + 1

	  WHILE @ii <= @SourceStringLength
	  BEGIN
	    SELECT @SourceCharacter = SUBSTRING(@Source, @ii, 1),
	           @Cost1 = @ii,
	           @Cost = @ii,
	           @Current_Row = '',
	           @jj = 1,
	           @Min_Cost = 4000
	    WHILE @jj <= @TargetStringLength
	    BEGIN  -- use formula to fill in the rest of the row
	      SET @Cost = @Cost + 1
	      --v1[j + 1] = Minimum(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
	      SET @Cost1 = @Cost1 - CASE WHEN @SourceCharacter = SUBSTRING(@Target, @jj, 1) THEN 1 ELSE 0 END
	      IF @Cost > @Cost1 SET @Cost = @Cost1
	      SET @Cost1 = UNICODE(SUBSTRING(@Previous_Row, @jj, 1)) + 1
	      IF @Cost > @Cost1 SET @Cost = @Cost1
	      IF @Cost < @Min_Cost SET @Min_Cost = @Cost
	      SELECT @Current_Row = @Current_Row + NCHAR(@Cost), @jj = @jj + 1
	    END
	    IF @Min_Cost > @MaxDistance return -1
	    -- copy current row to previous row for next iteration
	    SELECT @Previous_Row = @Current_Row, @ii = @ii + 1
	  END
    DECLARE @max int
    IF len(@source) >= len(@target)
      SET @max = LEN(@source)
    ELSE
      SET @max = LEN(@target)
		DECLARE @ret FLOAT
		IF (cast(@Cost as float) / cast(@max as float)) > 1
			SET @ret = 1
	  ELSE
			SET @ret = cast(@Cost as float) / cast(@max as float)
		RETURN @ret
	END
