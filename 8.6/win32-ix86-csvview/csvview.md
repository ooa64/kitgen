# csvview - tootl to review tablular files .csv, .dbf, .xls, .xlsx

Usage: csvview ?-option value ...? ?filename?

    -filename ""
    -filetype ""
    -encoding ""
    -theme ""
    -scale ""
    -font ""
    -width 100
    -height 30
    -limit 1000
    -bulk 100
    <CSV options>

## CSV

### The program will normally read all data. The following options modify this behaviour:

-excludefields FIELDINDICES

Specifies the list of indices of fields that are not to be included in the returned data. The corresponding fields will not be included even if they are specified via the -includefields option. If unspecified or an empty list, fields are included as per the -includefields option.

-includefields FIELDINDICES 	

Specifies the list of indices of fields that are to be included in the returned data unless excluded by the -excludefields option. Any fields whose indices are not present in FIELDINDICES will not be included in the returned rows. If unspecified or an empty list, all fields are included subject to the -excludefields option.

-skipblanklines BOOLEAN

If specified as true (default), empty lines are ignored. If false empty lines are treated as rows with no fields.

-skiplines LINELIST

If specified, LINELIST must be a list of integer line numbers (first line being at position 0). The corresponding lines are skipped and not included in the returned data. The line numbering includes commented lines if comments are enabled.

-startline LINENUM

If specified, the first LINENUM files of input are ignored. Note this includes commented lines if comments are enabled.

### Program attempts to guess the format of the data using heuristics that may not work for all files.

The following options collectively specify the format of the CSV data.

-comment COMMENTCHAR

Specifies the character to use as a comment leader. All characters on a line after COMMENTCHAR are ignored. COMMENTCHAR must be an ASCII character. If COMMENTCHAR is the empty string (default), comment recognition is disabled.

-delimiter DELIMCHAR
	
Specifies the delimiter character that separates fields. Defaults to the , (comma) character.

-doublequote BOOLEAN
	
Controls how the quote character inside a field value is treated. If specified as true (default), quote characters in a field are expected to be represented by doubling them. If false, they are expected to be preceded with an escape character.

-escape ESCCHAR

If specified, any character appearing after ESCCHAR is treated as an ordinary character with no special meaning. If unspecified or specified as an empty string, the escaping mechanism is disabled. ESCCHAR must be an ASCII character or an empty string.

-quote QUOTECHAR
	
Specifies the character used for quoting when a field contains special characters such as the delimiter or line terminators. If set to the empty string, the input is assumed to have no quoting character and special characters, if any, are expected to have used the escaping mechanism. Defaults to the double quote character.

-skipleadingspace BOOLEAN
	
If specified as true, leading space characters in fields are stripped. If false (default), it is retained.

##
