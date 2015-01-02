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
* Cross-platform flat text storage
* Option to predefine fielddefs
* Master/detail filtering
* Referential integrity
* Parameterized queries

More information
================
ZMSQL package is based on TBufDataset and TJanSql components. It consists of 3 components: 
1. ZMConnection 
2. ZMQueryDataset
3. TZMReferentialKey

TZMConnection defines the folder containing CSV (really semicolon-separated) tables with .txt extension. 
In ZMSQL, a "database" is a folder containing CSV tables. These files need to include field names as the first line (the TSDFDataSet setting FirstLineAsSchema).
New properties compared to parent:
* DecimalSeparator: used-definiing display setting for formatting ftFloat fields. Does not affect data storage format

TZMQueryDataset is a TBufDataset descendent, using TJanSQL database engine for executing SQL queries on CSV tables, TSDFDataset for loading data from CSV tables and Dbexporter for exporting its data to CSV table.

ZMQueryDataset can load data both from CSV table and from an executed SQL query. 
It can also copy data from some other dataset.
It adds properties/methods to its TBufDataset ancestor:

New properties:
* SQLText
* QueryExecuted
* TableName
* TableLoaded
* TableSaved
* PersistentSave: save CSV dataset after each AfterPost event

New methods:
* QueryExecute
* EmptyDataSet
* ClearDataSet
* CopyFromDataset
* SortDataset
* LoadFromCSV
* SaveToCSV: save to CSV file, optionally with user-defined decimal separator

TZMReferentialKey provides a link between master and detail datasets. It represents a referential key and enables referential integrity (update/insert/delete) between them.
It defines linking fields and the kind of referential integrity (set of (rkInsert, rkUpdate, rkDelete).
Important to note: master/detail filtering and referential integrity are implemented as separate independent features.
* FBulkInsert:Boolean; --> used to supress some events during loading data from a query or from CSV
* FOldRecord:TZMBufDataSet; -->used to store old values in a record before update-->needed for rkUpdate referential integrity
* procedure CopyARowFromDataset(pDataset: TDataSet);-->used to copy a row from original ZMQueryDataSet to FOldRecord
* procedure UpdateFOldRecord;--> updates FOldRecord on AfterScroll, AfterPost
* procedure DoAfterScroll;override;-->used for master/detail and referential integrity handling (refreshing FOldRecord)
* procedure DoBeforeDelete;override;-->used for rkDelete referential integrity
* procedure DoBeforePost;override;-->used for rkUpdate referential integrity
* procedure DoAfterInsert;override;-->used for rkInsert referential integrity
* procedure DoAfterPost;override;-->used for referential integrity handling (refreshing FOldRecord)
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


Global version history
======================
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

License
=======
Written by Zlatko Matic (matalab@gmail.com or matic.zlatko@gmail.com)
Modified LGPL and MPL 1.1 license: static and dynamic linkin both allowed, even in commercial applications.
Please see the individual licenses in the source files for details
Contains:
ZMSQL units, including zmbufdataset.pas, zmconnection.pas, zmquerydataset.pas, zmreferentialkey.pas: FPC modified LPGL
JanSQL units, including JanSQL.pas, janSQLExpression2.pas, janSQLStrings.pas, janSQLTokenizer.pas by Jan Verhoeven: Mozilla Public License Version 1.1 (MPL)
mwStringHashList.pas by Martin Waldenburg: Mozilla Public License Version 1.1 (MPL)