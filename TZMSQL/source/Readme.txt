ZMSQL - TBufDataset SQL enhanced in-memory database
by Zlatko Matic

Please see
http://lazarus.freepascal.org/index.php/topic,13821
http://wiki.lazarus.freepascal.org/ZMSQL

for original information.

Download current zmsql version from:
http://sourceforge.net/projects/lazarus-ccr/files/zmsql/

What is it
==========
ZMSQL is an open source, SQL enhanced in-memory database for FreePascal (FPC), operating with semicolon-separated values flat text tables. 
Completely written in Pascal, it has no dependencies on external libraries.
It offers:
* Cross-platform flat text storage (in .csv file)
* Option to predefine fielddefs and persistent fields
* Master/detail filtering
* Referential integrity
* Parameterized SQL queries

License
=======
Written by Zlatko Matic (matalab@gmail.com or matic.zlatko@gmail.com)
Modified LGPL and MPL 1.1 license: static and dynamic linkin both allowed, even in commercial applications.
Please see the individual licenses in the source files for details
Contains:
ZMSQL units, including zmbufdataset.pas, zmconnection.pas, zmquerydataset.pas, zmreferentialkey.pas: FPC modified LPGL
JanSQL units, including JanSQL.pas, janSQLExpression2.pas, janSQLStrings.pas, janSQLTokenizer.pas by Jan Verhoeven: Mozilla Public License Version 1.1 (MPL)
mwStringHashList.pas by Martin Waldenburg: Mozilla Public License Version 1.1 (MPL)

More information
================
ZMSQL package is based on TBufDataset and TJanSql components. It consists of 3 components: 
1. ZMConnection 
2. ZMQueryDataset
3. TZMReferentialKey

TZMConnection defines the folder containing CSV (really semicolon-separated) tables with .csv extension. 
In ZMSQL, a "database" is a folder containing CSV tables. These files need to include field names as the first line (the TSDFDataSet setting FirstLineAsSchema).

TZMQueryDataset is a TBufDataset descendent, using TJanSQL database engine for executing SQL queries on CSV tables, TSDFDataset for loading data from CSV tables and Dbexporter for exporting its data to CSV table.

ZMQueryDataset can load data both from CSV table and from an executed SQL query. 
It can also copy data from some other dataset.

It adds many properties/methods to its TBufDataset ancestor, of which most important are:

New properties:
* SQLText - janSQL query
* QueryExecuted - calls QueryExecute method which loads SQL query resultset into dataset.
* TableName - Name of a .csv file (without extension)
* TableLoaded - calls LoadFromtable method which loads data from CSV file.
* TableSaved - calls SaveToTable and saves to CSV file.
* PersistentSave: automatically save CSV dataset after each AfterPost event

New methods:
* QueryExecute 
* EmptyDataSet - deletes all records
* ClearDataSet - deletes records and fields
* CopyFromDataset - copies data from any dataset
* SortDataset - sorts ascending/descending by a column (field)
* LoadFromTable - loads data from CSV file (specified in TableName)
* SaveToTable -  saves to CSV file (TableName), optionally with user-defined decimal separator

TZMReferentialKey provides a link between master and detail datasets. It represents a referential key and enables referential integrity (update/insert/delete) between them.
It defines linking fields and the kind of referential integrity (set of (rkInsert, rkUpdate, rkDelete).
Important to note: master/detail filtering and referential integrity are implemented as separate independent features.
* property MasterReferentialKeys:TList read FMasterReferentialKeys write SetMasterReferentialKeys;-->stores all referential keys for which a ZMQueryDataSet is MasterDataSet in referential integrity relation.
* property SlaveReferentialKeys:TList read FSlaveReferentialKeys write SetSlaveReferentialKeys; -->stores all referential keys for which a ZMQueryDataSet is SlaveDataSet in referential integrity relation.
* property DisableMasterDetailFiltration:Boolean read FDisableMasterDetailFiltration write SetDisableMasterDetailFiltration;  -->used to temporarily disable master/detail filtering in DoFilterRecord
* procedure DoFilterRecord: Enabled Name=Value and Name behavior for MasterFields property.
  If Name=Value pair is used for an item in MasterFields property, Name corresponds to a field in detail dataset,
  while Value corresponds to master dataset. Otherwise, value indicates the name of the field in both dataset that must be the same.


Field definitions in ZMSQL
==========================
You can use predefined fielddefs (and their field types) created during designtime. If you don't, ZMSQL will create fielddefs on-the-fly during runtime.
If you predefine fielddefs during designtime and their number (TODO: to inspect matching of field names as well) matches the number of fields in loading JanSQL dataset or CSV dataset, ZMSQL will use existing fielddefs. Otherwise, it will delete previous fielddefs and recreate new fielddefs.
Bear in mind that you have to manually refresh DBGrids in order to refresh columns. Do it by refreshing the datasource component, eg.
Datasource1.Enabled:=False; //Manual refresh of linked DBGrid
Datasource1.Enabled:=True;
Why use design-time defined fielddefs? Simply because it is more efficient. JanSQL database engine is typeless. Everything is basically a string. Thus, ZMSQL can't know what field types in the resultset are, and it will create ftString fields.
Therefore, if you know what field types should be used and want to further process ZMQueryDataset data, it is better to set fielddefs during designtime.

Open issues/improvement ideas
=============================
1. TBufDataset bug
Currently TBufDataSet (ancestor of TZMQueryDataSet) has a bug 
(http://bugs.freepascal.org/view.php?id=19631 is solved!)
that causes Refresh method to delete all records

2. Slow query execution in JanSQL
Extremely slow query execution when more than one table joined in query when there is an additional where clause in the query. 
It can be overcome with the "ASSIGN TO variable" non-standard expression
First execute query on a table with where clasue, assign resultset to a variable and then use
the variable in a second query (instead of the table).

Thus, instead of:
"SELECT ordrs.ordr AS order, ordrs.ordr_type AS order type,ordrs.prdct AS product,ordrs.prdct_dscr AS product description,ordrs.prdct_targ_qty AS order quantity,ordrs.prdct_targ_qty_unt AS order unit,rqrmts.cmpnt AS component,rqrmts.cmpnt_dscr AS component description,rqrmts.cmpnt_rqrd AS required quantity of component FROM ordrs,rqrmts WHERE ordrs.ordr=rqrmts.ordr AND ordrs.prdct=10010356;",
use this non-standard SQL expression:
"ASSIGN TO temp_ordrs SELECT * from ordrs WHERE prdct=10010356;
SELECT temp_ordrs.ordr AS order, temp_ordrs.ordr_type AS order type,temp_ordrs.prdct AS product,temp_ordrs.prdct_dscr AS product description,temp_ordrs.prdct_targ_qty AS order quantity,temp_ordrs.prdct_targ_qty_unt AS order unit,rqrmts.cmpnt AS component,rqrmts.cmpnt_dscr AS component description,rqrmts.cmpnt_rqrd AS required quantity of component FROM temp_ordrs,rqrmts WHERE temp_ordrs.ordr=rqrmts.ordr;"

3. JanSQL has problems with typecasts.
Temporary solution: Enclose every numerical expression with ASNUMBER() function, so that jansql treats it as number.

4. Parameter support is currently quite limited. 
Basically, named parameters must be used and they are replaced by its values as literal strings.
You must enclose parameter identifiers in SQL string by quotes!

5. Multiline support
Investigate setting the sdfdata.AllowMultiline property to true when required to allow CSV data that contains line breaks.
See http://bugs.freepascal.org/view.php?id=17285
Not sure whether JanSQL database engine is able to handle this?
The parameters set for SdfDataset in zmsql corresponds to the csv format that JanSQL uses

JanSQL database engine SQL dialect
===============================
janSQL database engine supports only a subset of standard SQL but the supported statements are sufficient for single-user desktop application.

table updates
janSQL loads tables automatically into memory when needed by a query. Any changes to tables (INSERT, UPDATE, DELETE) are performed in memory. Tables are saved to disk when you use 
the COMMIT statement. The only exceptions to this are the CREATE TABLE statement, where the new table is saved to disk immediately and the DROP TABLE statement, where the table is 
immediately deleted from both memory and disk.

Indexes
janSQL does not use indexes. You will find that for single-user desktop applications running in memory there is no urgent need for indexes.

Case sensitivity
janSQL is case-insensitive for its keywords: you can use both SELECT and select.

Non-standard
janSQL has several non-standard SQL statements for manipulation of recordsets.
•	ASSIGN TO 
•	SAVE TABLE 
•	RELEASE TABLE

Compound Queries
In MightyQuery, you can execute multiple queries in a batch. Query expressions in a compound query must be separated by semi-colon. 
By using the non-standard ASSIGN TO statement you can store the result of a select query as a named variable that can be used in subsequent queries. This resembles SQL stored 
procedures in other database systems.

SQL syntax

A) Data Definition Language

CONNECT TO
Connects to a database. In janSQL a database is a folder. Tables are stored in this folder as delimited text files with the .txt extension.
Syntax:
CONNECT TO 'absolute-folder-path'

Example:
 	connect to 'G:'  
 
Notes
This is always the first statement that you use with janSQL. All other SQL statements require that the engine knows which folder to use.

CREATE TABLE
Creates a new table in the current catalog.
Syntax:
 	CREATE TABLE tablename (field1,[fieldN])
Example:
 	CREATE TABLE users (userid,username,accountname, accountpassword)
Notes
janSQL does not use fieldtypes. Everything is stored as text. Internally janSQL treats all data as variants. This means that in your SQL queries you can use fields pretty much the way you 
want to.

DROP TABLE
Drops a table from the database.
Syntax:
DROP TABLE tablename
Syntax:
DROP TABLE users
Notes
Use with care, because it deletes a file from hard disk..

ALTER TABLE
Allows you to alter the structure of a table.
Syntax:
 	ALTER TABLE ADD COLUMN columnname
ALTER TABLE DROP COLUMN columnname
You can only add or drop one column at the time.

B) Data Manipulation Language

SELECT FROM
Allows you to select data from one or two tables.
Syntax:
SELECT fieldlist FROM tablename
  	SELECT fieldlist FROM tablename WHERE condition
  	SELECT fieldlist FROM tablename1 [alias1], tablenameN [aliasN]
 	SELECT fieldlist FROM tablename1 [alias1], tablenameN [aliasN] WHERE condition

fieldlist can be * for selecting all fields or field1[,fieldN]
field: fieldname [AS fieldalias]
condition: see the WHERE topic.

Notes
When you join two or more tables  you must use fully qualified field names: tablename.fieldname in the WHERE clause. Both tablenames and fieldnames can be aliased.
 	SELECT u.userid as mio, u.username as ma, p.productname as muu
  	FROM users u,products p
  	WHERE u.productid=p.productid
Using a table alias can save you typing.
  	select products.productname as product,count(users.userid) as quantity
  	from users,products
  	where users.productid=products.productid
  	group by product
  	having quantity>10
  	order by product desc
 
The example above shows you that in the WHERE clause you refer to source tables (e.g. products.productid) where as in the GROUP BY, HAVING and ORDER BY clause, you refer to the 
result table.
Always use an aliased field name when using an aggregate function:
  	count(users.userid) as quantity
 
WHERE
The WHERE clause can be used together with the SELECT, UPDATE and DELETE clauses.
Syntax:
  	WHERE condition
 
condition
The condition is an expression that must evaluate to a boolean true or false. The following operators are allowed:

Arithmetic:
+ - * / ( )

Logic:
and, or 

comparison:
< <= = > >= 

string constants:
e.g. 'Jan Verhoeven' 

numeric constans:
e.g. 12.45

fieldnames
e.g. userid, users.userid

IMPORTANT NOTE: Sometimes JanSQL engine can't process WHERE clause if there are several conditions and joins. In that case application will freeze.
Therefore, try to simplify WHERE clause of the main expression by filtering one of the joined tables prior the main expression. Split the main query into few steps.
This means you have to split the main expression into, for example, two expressions and assign the first one to a variable (ASSIGN TO) that you will use instead of the original table.


IN
e.g.
   	userid IN (300,401,402)
   	username IN ('Verhoeven','Smith')

LIKE
e.g.
 	 username Like '%Verhoeven'


You can use the % character as a placeholder to match any series of characters:
 	 '%Verhoeven' will match Verhoeven at the end of username
  	'Verhoeven%' will match Verhoeven at the beginning of username
 	 '%Verhoeven%' will match Verhoeven anywhere in username
  

Sub queries

You can use a subquery after the IN clause. Only non-correlated sub queries are allowed at the moment. A sub query must select a single field from a table. A sub query is executed at 
parsing time and returns a comma seperated list of values that replaces the query text in the IN clause. A sub query must be enclosed by brackets.
Example:
select * from users where productid in (select product id from products where productname like 'Ico%')

Notes
When using a SELECT with a join between 2 tables you must use fully qualified names (tablename.fieldname) in every part of the query. In all other cases (UPDATE, INSERT) you must use 
the short form fieldname without the tablename.

GROUP BY
Allows you to group data according grouping fields.
Syntax:
  	group by fieldlist
fieldlist is a comma seperated list of one or more fields that you want to grouping to be applied.
Example:
  	select count(userid), username, productid
  	from users
  	group by productid
  	order by productid
 
Aggregate functions
You can apply the count, sum, avg, max, min, stddev function to an input field. When you use these functions without a GROUP BY clause, the resultset will contain only one row.

HAVING
Allows you to filter a recordset resulting from a GROUP BY clause.
Syntax:
 	HAVING expression 
Example:
  	select count(userid), username, productid
 	from users
  	group by productid
 	having userid>10
  	order by productid
 
Notes
Experienced SQL users will notice that janSQL uses a non-standard syntax in the HAVING clause. Instead of the standard having count(userid)>10, in janSQL you just use the name of the 
base table field, in this case userid.

You should be aware of the difference between the WHERE clause and the HAVING clause. The WHERE clause is applied to table(s) in the FROM clause. The HAVING is applied after filtering 
with where and grouping with group by have been applied. The same applies to the ORDER BY clause which is also applied to the final result set.

ORDER BY
Allows you to sort the resulting recordsets.
Syntax:
   	ORDER BY orderlist
Example:
   	select * from users order by #userid asc, productid desc  

orderlist is a comma seperated list of one or more order by components:
component1[,componentN]
ordercomponent:
[#]fieldname [ASC|DESC]

By placing the optional # before a fieldname it will be treated as a numeric field in the sort. Remember that in janSQL all data is stored as text.
After the fieldname you can optionally put ASC for an ascending sort, or DESC for a descending sort. When you omit the sort direction the default ascending sort order is used.

ASSIGN TO
Allows you to assign the result of a SELECT statement to a named recordset that can be referred to in subsequent statements. This is a non-standard 
SQL statement. ASSIGN TO is like a variable assignment. You can create very complex compound queries with ASSIGN TO.
Syntax:
  	ASSIGN TO tablename selectstatement
Example:
  	ASSIGN TO mis SELECT userid, username FROM users
If tablename allready exists in the catalog then an error occurs. 
When tablename does not exist in the catalog but was allready assigned to then the existing recordset is overwritten.

Notes
Make sure that you use output field alias names when you ASSIGN TO using a  SELECT with joined tables.

When you execute the ASSIGN TO the given name will be assigned to the new recordset and the recordset itself will not be released until you use RELEASE TABLE.

RELEASE TABLE
Allows you to release any open table from memory, including intermediate tables created with ASIGN TO. This is a non-standard SQL statement.
Syntax:
  	RELEASE TABLE tablename
Example:

  	ASSIGN TO mis SELECT * FROM users
  	RELEASE TABLE mis

SAVE TABLE
Allows you to save any open table, including intermediate tables, to a file. This is a non-standard SQL statement.
Syntax:
 	SAVE TABLE tablename
When tablename is not open, an error occurs. When you save an intermediate table (created with ASSIGN TO), the intermediate table becomes a persistant table that is also saved with the 
COMMIT statement.
Example:
ASSIGN TO mis SELECT * FROM users
 	SAVE TABLE mis
Notes
Once you have saved an intermediate table with TABLE SAVE you can not ASSIGN TO anymore.

INSERT INTO
Allows you to insert data in a table, either row by row or from a recordset resulting from a SELECT.
Syntax:
 	 INSERT INTO tablename [(column1[,column])] VALUES (field1[,fieldN])
 	 INSERT INTO tablename selectstatement
Example:
  	 INSERT INTO users VALUES (600,'user-600');
 	 INSERT INTO users (userid,username) VALUES (601,'user-601');
 	 INSERT INTO users SELECT * FROM users WHERE userid>400
Notes
When you insert records using a sub select you must make sure that the output fields of the sub select match the fieldnames of tablename. Only values of matching field will be inserted.

UPDATE
Allows you to update existing data.
Syntax:
  	UPDATE tablename SET updatelist [WHERE condition]
updatelist:
field1=value1[,fieldN=valueN]

condition: see WHERE  for the optional condition

DELETE FROM
Allows you to delete data.
Syntax:
  	DELETE FROM tablename WHERE condition
condition: see WHERE clause for the condition.

C) Functions

In janSQL you can use functions wherever you can use an expression to be calculated (Calculated output fields, WHERE clause, HAVING clause).

Use extra brackets around function parameters when you have a function with more than one parameter:

  SELECT trunc((userid/7),2) as foo FROM users
 
and not:

  SELECT trunc(userid/7,2) as foo FROM users

Conversion

fix(expression,precision)
Returns the string presentation of (numeric) expression with precision number of decimals.

  select fix((userid/7), 2) as bobo from users order by bobo
 
You can also use TRUNC i.s.o. FIX. 

asnumber(expression)
Returns (number or string) expression as number. If expression is not a valid floating point number then the function returns 0.

FORMAT function
Formats a integer or floating point value to a string in a way specified by a format string.
Syntax:
  	format(value,formatstring) 
Example:
  	update users set userid=format(userid,'%.8d')

Format strings have the following form:
[literalstring]"%" [width] ["." prec] type

•	An optional literal string that is copied to the output
•	An optional width specifier, [width]
•	An optional precision specifier, ["." prec]
•	The conversion type character, type

The following table summarizes the possible values for type:

d
Decimal. The argument must be an integer value. The value is converted to a string of decimal digits. If the format string contains a precision specifier, it indicates that the resulting string 
must contain at least the specified number of digits; if the value has less digits, the resulting string is left-padded with zeros.

u
Unsigned decimal. Similar to 'd' but no sign is output.

e
Scientific. The argument must be a floating-point value. The value is converted to a string of the form "-d.ddd...E+ddd". The resulting string starts with a minus sign if the number is negative. 
One digit always precedes the decimal point.The total number of digits in the resulting string (including the one before the decimal point) is given by the precision specifier in the format 
string—a default precision of 15 is assumed if no precision specifier is present. The "E" exponent character in the resulting string is always followed by a plus or minus sign and at least three 
digits.

f
Fixed. The argument must be a floating-point value. The value is converted to a string of the form "-ddd.ddd...". The resulting string starts with a minus sign if the number is negative.The 
number of digits after the decimal point is given by the precision specifier in the format string—a default of 2 decimal digits is assumed if no precision specifier is present.

g
General. The argument must be a floating-point value. The value is converted to the shortest possible decimal string using fixed or scientific format. The number of significant digits in the 
resulting string is given by the precision specifier in the format string—a default precision of 15 is assumed if no precision specifier is present.Trailing zeros are removed from the resulting 
string, and a decimal point appears only if necessary. The resulting string uses fixed point format if the number of digits to the left of the decimal point in the value is less than or equal to the 
specified precision, and if the value is greater than or equal to 0.00001. Otherwise the resulting string uses scientific format.

n
Number. The argument must be a floating-point value. The value is converted to a string of the form "-d,ddd,ddd.ddd...". The "n" format corresponds to the "f" format, except that the 
resulting string contains thousand separators.

m
Money. The argument must be a floating-point value. The value is converted to a string that represents a currency amount. The conversion is controlled by the CurrencyString, 
CurrencyFormat, NegCurrFormat, ThousandSeparator, DecimalSeparator, and CurrencyDecimals global variables, all of which are initialized from the Currency Format in the International 
section of the Windows Control Panel. If the format string contains a precision specifier, it overrides the value given by the CurrencyDecimals global variable.

s
String. The argument must be a string value. The string  is inserted in place of the format specifier. The precision specifier, if present in the format string, specifies the maximum length of the 
resulting string. If the argument is a string that is longer than this maximum, the string is truncated.

x
Hexadecimal. The argument must be an integer value. The value is converted to a string of hexadecimal digits. If the format string contains a precision specifier, it indicates that the resulting 
string must contain at least the specified number of digits; if the value has fewer digits, the resulting string is left-padded with zeros.

 Date functions 

Several date functions make working with date strings easier.

YEAR
Extracts the integer year part of a yyyy-mm-dd date string.

MONTH
Extracts the integer month part of a yyyy-mm-dd date string.

DAY
Extracts the integer day part of a yyyy-mm-dd date string.

WEEKNUMBER
Returns the integer weeknumber of a yyyy-mm-dd date string.

EASTER
Returns the easter yyyy-mm-dd date string of a given integer year.

DATEADD
Adds a given number of time intervals to a given data and returns the resulting data as a yyyy-mm-dd data string.
Syntax:
 	 DATEADD(interval,number,datestring)
 
Interval can be: 'd' (day), 'm' (month), 'y' (year), 'w' (week), 'q' (quarter).
Number must be an integer number.
datestring must be in the yyyy-mm-dd format.

 String Functions 

janSQL comes with a range of functions that work on strings.

soundex(expression)
Calculates the soundex value of (string) expression. Only usefull with english terms.

lower(expression)
Converts (string) expression to lower case.

upper(expression)
Converts (string) expression to upper case.

trim(expression)
Trims (string) expression from leading and trailing spaces.

left(expression,count)
Returns the first count characters of expression

right(expression,count)
Returns the last count characters of expression

mid(expression,from,count)
Returns count characters of expression starting at from.

length(expression)
Returns the length of (string) expression. Can be used to e.g. select fields that exceed a given length.

replace(source,oldpattern,newpattern
Replaces oldpattern with new pattern in the source string. Is case-insensitive.
 	UPDATE users SET username=replace(username,'user-','foo-')
 
substr_after(source,substring)
Returns the part of source that comes after substring. If substring is not found an empty string is returned.

substr_before(source,substring)
Returns the part of source that comes before substring. If substring is not found an empty string is returned.

 Numeric Functions 

Numeric functions work on strings as if they were numbers. Although janSQL is based on strings you can still enter values like 1234, which can be treated like numbers.

sqr(expression)
Calculates the square of (numeric) expression.

sqrt(expression)
Calculates the square root of (numeric) expression.

sin(expression)
Calculates the sin of (numeric) expression.

cos(expression)
Calculates the cos of (numeric) expression.

ceil(expression)
Returns the lowest integer greater than or equal to (numeric) expression.

floor(expression)
Returns the the highest integer less than or equal to (numeric) expression.

Global version history
======================

ZMSQL version 0.1.19, 08.02.2015: by Zlatko Matić
*New component TZMQueryBuilder, based on Open QBuilder Engine, is added to the zmsql package. 
TZMQueryBuilder uses TOQBEngineZmsql, which is TOQBEngine descendant.
TOQBEngineZmsql is in based on code of the Open QBuilder Engine for SQLDB Sources created by Reinier Olislagers, modified and adapted for the ZMSQL by Zlatko Matić.
It incorporates QBuilder visual query builder(Copyright (c) 1996-2003 Sergey Orlik , Copyright (c) 2003 Fast Reports, Inc.)
*Added procedure TZMConnection.GetTableNames(FileList: TStrings);
*Added procedure TZMQueryDataSet.LoadTableSchema;

ZMSQL version 0.1.18, 10.04.2014: by Zlatko Matić
*Bugfix release. There was funny bug in zmquerydataset destroy method - dataset would be saved prior destroying if persistent save was enebaled.
This was wrong, causing saving CSV file copy in wrong directories.

ZMSQL version 0.1.17, 07.03.2014: by Mario Ferrari
*Error situations that used ShowMessage now raise a generic exception containing the message itself. Only one ShowMessage remains for a design-time case.

ZMSQL version 0.1.16, 28.01.2014: by Zlatko Matić
*Internal optimizations and bugfixes.
*Creation of JanSQL instances moved from ZMConnection to ZMQueryDataset, in order that ZMQueryDataset can be used in multithreaded applications.
*New properties (ReferentialUpdateFired, ReferentialDeleteFired, ReferentialInsertFired) that tells that a referential action is in progress.

ZMSQL version 0.1.15, 28.01.2014: by Zlatko Matić
*Internal optimizations and bugfixes.
*Autoincrement fields (ftAutoInc) are now working.
*Improved visibility of TDataset methods and properties.
*ZMQueryDataset now works with TBufDataset as ancestor (as in CodeTyphon v.4.70). ZMBufDataset upgraded to the current TBufDataset in CodeTyphon v. 4.70.
*Added property MasterDetailFilter: Boolean which switches master/detail filtration on/off.
*Removed property DecimalSeparator. ZMSQL now use system settings for decimal and thousand separator.
*ZMQueryDataset can handle float value even if thousand separator is present (in a .csv file).
*Better handling locale settings and conversion from ANSI to UTF8.
*Persistent fields are working now. (Solved by a trick: persistent fields loaded from .lfm are recreated, propertie from old fields are copied to new fields and old fielsa are deleted.                                               

ZMSQL version 0.1.14, 01.01.2014: by Zlatko Matić
* Internal optimizations.
* Based on TZMBufDataset instead TBufDataset, because problems with current TBufDataset version.
* ZMQueryDataset now loads from and saves to files with .csv extension, instead of .txt extension.
* Added ManageFields method, which decides what to do with Fields and FieldDefs.
* Reworked InspectFields procedure, better deduction of FieldDefs and Fields status.
* Enabled automatic creation of persistent fields objects from predefined fielddefs.
* New published properties: DynamicFieldsCreated, PeristentFieldsCreated, MemoryDataSetOpened,
* New public methods: CreateDynamicFieldsFromFieldDefs, CreatePersistentFieldsFromFieldDefs;
* Added "$DEFINE ZMBufDataset" compiler directive.    

ZMSQL version 0.1.13, 13.01.2013: by Zlatko Matić
* Few bug fixes.
* TZMbufdataset replaced with current TBufDataset as ancestor. Tested with current FPC 2.7.1 in CodeTyphon v. 3.10.
If this does not work for your FPC version, then replace TBufDataSet with TZMBufDataset as ancestor.
The TZMBufDataset will stay present latent inside the package, just in case that further development od TBufDataSet goes in direction incompatible with zmsql.
*Added procedure InternalRefresh;override;
TBufDataSet's InternalRefresh does troubles, so it is overriden to do nothing.
It seems that all functionalities which ZMQueryDataset needs are implemented inside TDataSet's Refresh method and that InternalRefresh is not needed at all.                                               

ZMSQL version 0.1.12, 12.02.2012: by Zlatko Matić
* Critical bug in DoBeforeDelete solved: The bug was causing referential deletion of all records, even those not related to master dataset.
* Few enhancements regarding persistent save functionality.  
      
ZMSQL version 0.1.11, 05.02.2012: by Zlatko Matić
* DoAfterScroll call added to DoFilterRecord,in order to referesh detail dataset after filtering master dataset.
* FormatSettings.QuoteStrings:=[qsAlways] added in SaveToCSV method, so that strings are saved enclosed in double guotes.
* FloatDisplayFormat property added to ZMConnection. If set, it will be applied to all connected zmquerydatasets and override TFloatField's settings defined in zmquerydatasets.
* SetFloatDisplayFormat method added. This method takes formatting from FloatDisplayFormat property of ZMConnection, if set.
* Call to SetFloatDisplayFormat added in FieldsFromScratch and FieldsFromFieldDefs.
* Since in Jansql DecimalSeparator:=SysUtils.DefaultFormatSettings.DecimalSeparator has been added,
so that jansql takes-over system decimal separator, the same is added to SaveToCSV method.
It means that now zmquerydataset executes queries, loads data from CSV and saves dataset to csv using system settings for decimal separator.
System settings can be, however, overriden by changing values of ZMConnection's properties DecimalSeparator and FloatDisplayFormat.  
* ZMFieldsFromFieldDefs renamed to FieldsFromFieldDefs; ZMFieldsFromScratch renamed to FieldsFromScratch.

ZMSQL version 0.1.10, 20 January 2012: by Zlatko Matić
* procedure CopyFromDataset rewritten in way that now it uses ZMFieldsFromScratch and ZMFieldFromFieldDefs methods for dynamical fields creation.
In case of previously defined fielddefs, they will be used, otherwise, fielddefs from a dataset will be copied to ZMQueryDataset.
* FSourceData expanded to sdOtherDataset. FOtherDatasetImport added.

ZMSQL version 0.1.9, 15 January 2012: by Zlatko Matić
* Bug fixes in DoFilterRecord and SetMasterSource procedures, to enable custom filtration working correctly.
* In procedure TZMQueryDataSet.ZMFieldsFromScratch added formula for setting MaxIndexes count.
The formula is: MaxIndexesCount:=(2*(self.FieldDefs.Count)+3).This default value includes ascending and descending index on every column, two default TBufDataset indexes and one spare index.
The formula is used in cases when LoadFromCSV or QueryExecute is called without prior FiedlDefs definition.
You can still set MaxIndexesCount to any value before calling CreateDataset. 
Note that in zmsql you can use function SortDataset (const pFieldName:String):Boolean that creates indexes on the fly.
* Bug fix in EmptyDataset method, so that it delete all records in case of active filter.                    

ZMSQL version 0.1.8, 08 January 2012: by Zlatko Matić
- Since there was no visible improvement in BufDataSet regarding "Refresh bug" for a very long time,
and it seems that TBufDataset is not maintained successfully any more, 
I have decided to base zmsql on last stable TBufDataset version that performed Refresh method correctly, 
which appears to be present in fpc 2.2.4. 
Therefore, new zmbufdataset.pas and zmbufdatasetparser.pp units are now actually downgraded to fpc 2.2.4. 
This choise will not change anymore and this is starting point for further independent development of zmbufdataset unit 
as direct ancestor of zmquerydataset. 
We can always come back to TBufDataset as direct ancestor of zmquerydataset (while preserving zmbufdataset as an alternative) 
if following criteria is met:
  1. DoFilterRecord method is virtual and protected.
  2. Refresh method works correctly 
Until then, zmbufdataset remains direct ancestor of zmquerydataset and will fork from TBufDataset development.
- Reconnecting of ZMConnection is added in QueryExecute and LoadFromCSV methods, each time data is loaded by query or import from csv.
This prevents peculiar inconsistences observed during query execution in some circumstances.
This odd behavior of jansql has to be throughly investigated... 
- "if not Acceptable then exit;" added After "inherited DoFilterRecord(Acceptable);",
in order to preserve normal filtering functionality with Filter and Filtered properties. 
      
ZMSQL version 0.1.7, 01 January 2012: by Zlatko Matić
- FDoReferentialUpdate:Boolean field added to signalize dsEdit state in DoBeforePost, which is then
used in DoAfterPost as signal to perform referential update. This solved bug that caused referential update of all records in case of insert.
- Added public read-only property OldRecord. This can be useful during run-time.  

ZMSQL version 0.1.6, 28 December 2011: by Zlatko Matić
- Referential update logic moved from DoBeforePost to DoAfterPost procedure, in order to solve problems with multilevel referential integrity.
- UpdateFOldRecord triggering moved from DoAfterScroll and DoAfterPost to DoBeforeInsert, DoBeforeDelete and DoBeforeEdit.
- Inspecting and matching of referential conditions for referential update changed from custom filtering to iteration 
and inspection for referential conditions for every record of SlaveDataset.
- Bugs in PrepareQuery and DoFilterRecord, as well as few other small bugs are solved.
- ZMBufDataSet updated with recent bufdataset changes.
- ZMBufDataSetParser added to package.  
- Bug in Disconnect procedure solved. 

Mercurial revision 15f0cfb99859: 4 September 2011
Added some things to JanSQL tokenizer and expression evaluator. Still needs implementation of those expressions (outer joins, select distinct etc.)

Version 0.1.5: 12 August 2011
Two small demo projects are included in the zip. First one demonstrates referential integrity, master/detail filtration, parameterized queries and difference between using predefined FieldDefs and FieldDefs created on the fly. The second one demostrates loading and saving to CSV table.

Improvements: ZMSQL now enables decimal separator to be chosen (new property in TZMConnection) for ftFloat field type. It does not influence default CSV save format, but only data representation.
Caution: Changing value of a ZMConnection.DecimalSeparator will change SysUtils.DefaultFormatSettings as well, so this will influence on the whole application!
If you leave ZMConnection.DecimalalSeparator empty, default format settings are going to be used

Added overloaded procedure, procedure SaveToCSV (pDecimalSeparator);overload; so that you can save a dataset with custom decimal separator. The regular SaveToCSV uses dot as decimal separator, because JanSQL database engine uses that format.

Version 0.1.4: 8 August 2011
Successfully implements REFERENTIAL INTEGRITY!
A simple test project is provided inside the package folder and demostrates new features from zmsql 0.1.3 and 0.1.4:
- queries with joined tables
- master/detail filtration/synchronization
- referential integrity (insert/update/delete)
- parameterized queries

Version 0.1.3: 2 August 2011
This version brings master/detail synchronization.
The test project now also demonstrates master/detail synchronization and parameterized queries.

Version 0.1.2: 28 July 2011
This version brings initial support for parameterized queries (it borrows TParams collection from SQLDB).
Currently, this support is very basic, parameters must be passed by name (ParamByName) and their values are passed as string literals to SQL string before query execution.
There is a Test project included in the package, where you can see how parameters are used.

Version 0.1.1: 26 July 2011
QueryExecute method fixed. SqlText TStrings property must be transformed to String prior to passing it JanSQL engine and spaces must be inserted between Sqltext lines.

Version 0.1.0: 13 July 2011

