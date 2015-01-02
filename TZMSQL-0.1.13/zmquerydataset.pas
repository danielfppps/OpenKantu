{*********************************************************}
{                                                         }
{                       ZMSQL                             }
{            SQL enhanced in-memory dataset               }
{                                                         }
{   Original developer: Zlatko Matić, 2009                }
{             e-mail: matalab@gmail.com                   }
{  Milkovićeva 6, Mala Ostrna, 10370 Dugo Selo,  Croatia. }
{                                                         }
{*********************************************************}
{
    This file is copyright (c) 2011 by Zlatko Matić    
    
    This source code is distributed under
    the Library GNU General Public License (see the file 
    COPYING) with the following modification:

    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent modules,
    and to copy and distribute the resulting executable under terms of your choice,
    provided that you also meet, for each linked independent module, the terms
    and conditions of the license of that module. An independent module is a module
    which is not derived from or based on this library. If you modify this
    library, you may extend this exception to your version of the library, but you are
    not obligated to do so. If you do not wish to do so, delete this exception
    statement from your version.

    If you didn't receive a copy of the file COPYING, contact:
          Free Software Foundation
          675 Mass Ave
          Cambridge, MA  02139
          USA   

    Modifications are made by Zlatko Matić and contributors for purposes of zmsql package.

 **********************************************************************}

{-----------------------------------------------------------------------------

The original developer of the code is Zlatko Matić
(matalab@gmail.com or matic.zlatko@gmail.com).

Contributor(s):

Last Modified: 12.02.2012

Known Issues:

- Extremely slow query execution when more than one table joined in query when there is
additional where clause in query. It can be overcomed with "ASSIGN TO variable" non-standard expression
-->first execute query on a table with where clasue, assign resultset to a variable and then use
the variable in second query (instead of the table).
- JanSQL has problems with typecasts.
- Parameters support is currently quite limited. Basically, named parameters must be used and they are replaced by its values as literal strings.
-->You must enclose parameter identifiers in SQL string by quotes!

History (Change log):

ZMSQL version 0.1.0, 13.07.2011
        ZMSQL released as free software
ZMSQL version 0.1.1, 26.07.2011
        - QueryExecute method fixed. SqlText TStrings property must be transformed to String
        prior passing to JanSQL engine and spaces must be inserted between Sqltext lines.
ZMSQL version 0.1.2, 28.07.2011
        - 28.07.2011: Rudimentary support for parameterized queries: property Parameters: TParams, procedure PrepareQuery,FPreparedSQL:String, FOriginalSQL:String
ZMSQL version 0.1.3, 02.08.2011
        - ZMQueryDataSet now inherits from TZMBufDataSet instead TBufDataSet, TZMBufDataSet is modified TBufDataset,
        that enables overriding of some methosds, such as DoFilterRecord-->neccessary for master/detail snychronization.
        - Master/detail filtration enabled: properties MasterDataSetTo, MasterFields, MasterSource
ZMSQL version 0.1.4, 08.08.2011
      - Referential integrity implemented:
      FBulkInsert:Boolean; --> used to supress some events during loading data from a query or from CSV
      FOldRecord:TZMBufDataSet; -->Used to store old values in a record before update-->needed for rkUpdate referential integrity
      procedure CopyARowFromDataset(pDataset: TDataSet);-->used to copy a row from original ZMQueryDataSet to FOldRecord
      procedure UpdateFOldRecord;--> updates FOldRecord on AfterScroll, AfterPost
      procedure DoAfterScroll;override;-->used for master/detail and referential integrity handling (refreshing FOldRecord)
      procedure DoBeforeDelete;override;-->used for rkDelete referential integrity
      procedure DoBeforePost;override;-->used for rkUpdate referential integrity
      procedure DoAfterInsert;override;-->used for rkInsert referential integrity
      procedure DoAfterPost;override;-->used for referential integrity handling (refreshing FOldRecord)
      property MasterReferentialKeys:TList read FMasterReferentialKeys write SetMasterReferentialKeys;-->stores all referential keys for which a ZMQueryDataSet is MasterDataSet in referential integrity relation.
      property SlaveReferentialKeys:TList read FSlaveReferentialKeys write SetSlaveReferentialKeys; -->stores all referential keys for which a ZMQueryDataSet is SlaveDataSet in referential integrity relation.
      property DisableMasterDetailFiltration:Boolean read FDisableMasterDetailFiltration write SetDisableMasterDetailFiltration;  -->used to temporary disable master/detail filtration in DoFilterRecord
      - procedure DoFilterRecord: Enabled Name=Value and Name behavior for MasterFields property.
        If Name=Value pair is used for an item in MasterFields property, Name corresponds to a field in detail dataset,
        while Value corresponds to master dataset. Otherwise, value indicates the name of the field in both dataset that must be the same.
ZMSQL version 0.1.5, 12.08.2011
      - SaveToCSV call added to DoAfterPost method, so that dataset is saved to CSV table on AfterPost event, if PersistentSave property is set to true.
      - Added procedure FormatStringToFloat(pFloatString: string):Float, used in procedures InsertDataFromCSV and InsertDataFromJanSQL.
      It is used for formatting ftFloat fields according to user defined format settings (property ZMConnection.DecimalSeparator).
      - Added procedure SaveToCSV(pDecimaSeparator: Char);overload; so that dataset can be exported with custom Float decimal separator.
ZMSQL commit 15f0cfb99859, 4 September 2011: by Zlatko Matić
      - janSQLExpression2.pas: Procedures proLOJ and procROJ added to handle Sybase-like operators ('*='; '=*') for outer joins.
      - janSQLTokenizer: added tosqlSELECTDISTINCT, tosqlINNERJOIN, tosqlLEFTOUTERJOIN, tosqlRIGHTOUTERJOIN,
      tosqlFULLOUTERJOIN, tosqlCROSSJOIN, tosqlON, tosqlUSING
ZMSQL commit, 16 December 2011: by Zlatko Matić
      - ZMQueryDataset: In DoFilterRecord "if ((FBulkInsert=False) and (DisableMasterDetailFiltration=False)) then begin" "(FBulkInsert=False)"
      is added in order to improve speed of bulk insert from CSV in master/detail related tables.
      - ZMBufDataSet updated with recent bufdataset changes.
      - ZMBufDataSetParser added to package.
      - Bug in PrepareQuery procedure solved
ZMSQL version 0.1.6, 28.12.2011: by Zlatko Matić
      - Referential update logic moved from DoBeforePost to DoAfterPost procedure, in order to solve
        problems with multilevel referential integrity.
      - UpdateFOldRecord triggering moved from DoAfterScroll and DoAfterPost to DoBeforeInsert, DoBeforeDelete and DoBeforeEdit.
      - Filtering of SlaveDataset with custom filter matching referential conditions, prior applying referential update to SlaveDataset
      is replaced with iteration through all records in slavedataset and inspecting referential conditions in every record.
ZMSQL version 0.1.7, 01.01.2012: by Zlatko Matić
      - FDoReferentialUpdate:Boolean field added to signalize dsEdit state in DoBeforePost, which is then
      used in DoAfterPost as signal to perform referential update. This solved bug that
      caused referential update of all records in case of insert.
      - Added public read-only property OldRecord
ZMSQL version 0.1.8, 08.01.2012: by Zlatko Matić
      - Reconnecting of ZMConnection is added in QueryExecute and LoadFromCSV methods, each time data is loaded by query or import from csv.
      This prevents peculiar inconsistences observed during query execution in some circumstances.
      This odd behavior of jansql has to be throughly investigated.
      - After "inherited DoFilterRecord(Acceptable);","if not Acceptable then exit;" added,
      in order to preserve normal filtering functionality with Filter and Filtered properties.
ZMSQL version 0.1.9, 15.01.2012: by Zlatko Matić
      * Bug fixes in DoFilterRecord and SetMasterSource procedures. Custom filtration now works correctly.
      * In procedure TZMQueryDataSet.ZMFieldsFromScratch added formula for setting MaxIndexes count.
      The formula is: MaxIndexesCount:=(2*(self.FieldDefs.Count)+3).
      * Bug fix in EmptyDataset method, so that it delete all records in case of active filter.
ZMSQL version 0.1.10, 20.01.2012: by Zlatko Matić
      * sdOtherDataset added to FSourceData. FOtherDataset added.
      * ZMFieldsFromScratch expanded to support CopyFromDataset.
      * CopyFromDataset rewritten.
ZMSQL version 0.1.11, 05.02.2012: by Zlatko Matić
      * DoAfterScroll call added to DoFilterRecord,in order to referesh detail dataset after filtering master dataset.
      * FormatSettings.QuoteStrings:=[qsAlways] added in SaveToCSV method, so that strings are saved enclosed in double guotes.
      * SetFloatDisplayFormat method added. This method takes formatting from FloatDisplayFormat property of ZMConnection, if set.
      * Call to SetFloatDisplayFormat added in FieldsFromScratch and FieldsFromFieldDefs.
      * Since in Jansql DecimalSeparator:=SysUtils.DefaultFormatSettings.DecimalSeparator is added,
      so that jansql takes-over system decimal separator, the same is added to SaveToCSV method.
      Now zmquerydataset executes queries, loads data from CSV and saves dataset to csv using system settings for decimal separator.
      System settings can be, however, overriden by changing values of ZMConnection's properties DecimalSeparator and FloatDisplayFormat.
ZMSQL version 0.1.12, 12.02.2012: by Zlatko Matić
      * Critical bug in DoBeforeDelete solved: The bug was causing referential deletion of all records, even those not related.
      * Few enhancements regarding persistent save functionality.
ZMSQL version 0.1.13, 13.01.2013: by Zlatko Matić
      * Few bug fixes.
      * TZMbufdataset replaced with current TBufDataset as ancestor. Tested with current FPC 2.7.1 in CodeTyphon v. 3.10.
      If this does not work for your FPC version, then replace TBufDataSet with TZMBufDataset as ancestor.
      The TZMBufDataset will stay present latent inside the package, just in case that further development od TBufDataSet goes in direction incompatible with zmsql.
      *Added procedure InternalRefresh;override;
      TBufDataSet's InternalRefresh does troubles, so it is overriden to do nothing.
      It seems that all functionalities which ZMQueryDataset needs are implemented inside TDataSet's Refresh method and that InternalRefresh is not needed at all.
-----------------------------------------------------------------------------}
unit ZMQueryDataSet;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  db, TypInfo, fpDBExport,fpcsvexport, fpstdexports, SdfData, StrUtils,
  {ZMBufDataset,} BufDataset, {, memds,}
  ZMConnection;

type

  TSourceData=(sdSdfDataset, sdJanSQL, sdOtherDataset);

  { TZMQueryDataSet }

  TZMQueryDataSet = class(TBufDataSet)
  {TZMQueryDataSet = class(TZMBufDataSet)}
  private
    FDisableMasterDetailFiltration: Boolean;
    FMasterFields: TStrings;
    FMasterSource: TDataSource;
    FOldMasterSource:TDataSource;
    FMasterDataSetTo: TList;
    FParameters: TParams;
    FPersistentSave: Boolean;
    FMasterReferentialKeys: TList;
    FSdfDatasetImport:TSdfDataset;
    FOtherDatasetImport:TDataset;
    FCSVExporterExport: TCSVExporter;
    FSlaveReferentialKeys: TList;
    FTableLoaded: Boolean;
    FTableName: String;
    FTableSaved: Boolean;
    FZMConnection: TZMConnection;
    FQueryExecuted: Boolean;
    FSQL: TStrings;
    FOriginalSQL:String;
    FPreparedSQL:String;
    FRecordCount:Integer;
    FFieldCount:Integer;
    FRecordsetIndex:Integer;
    FSourceData:TSourceData;
    FBulkInsert:Boolean;
    FOldRecord:{TZMBufDataSet} TBufDataSet;
    FDoReferentialUpdate:Boolean;
    procedure SetConnection(const AValue: TZMConnection);
    procedure SetDisableMasterDetailFiltration(const AValue: Boolean);
    procedure SetMasterDataSetTo(const AValue: TList);
    procedure SetMasterReferentialKeys(const AValue: TList);
    procedure SetSlaveReferentialKeys(const AValue: TList);
    procedure SetZMConnection(const AValue: TZMConnection);
    procedure SetMasterFields(const AValue: TStrings);
    procedure SetMasterSource(const AValue: TDataSource);
    procedure SetParameters(const AValue: TParams);
    procedure SetPersistentSave(const AValue: Boolean);
    procedure SetTableLoaded(const AValue: Boolean);
    procedure SetTableName(const AValue: String);
    procedure SetTableSaved(const AValue: Boolean);
    procedure SetQueryExecuted(const AValue: Boolean);
    procedure SetSQL(const AValue: TStrings);
    { Private declarations }
    procedure PassQueryResult;
    procedure FieldsFromFieldDefs;
    procedure FieldsFromScratch;
    procedure EmptySdfDataSet;
    procedure ClearSdfDataSet;
    procedure InsertDataFromCSV;
    procedure InsertDataFromJanSQL;
    function InspectFieldDefs:Boolean;
    procedure UpdateMasterDataSetTo;
    procedure CopyARowFromDataset(pDataset: TDataSet);
    procedure UpdateFOldRecord;
    function FormatStringToFloat (pFloatString:string):Double;
    procedure SetFloatDisplayFormat;
  protected
    { Protected declarations }
    procedure DoFilterRecord(out Acceptable: Boolean);
    procedure DoAfterScroll;override;
    procedure DoBeforeDelete;override;
    procedure DoBeforeInsert;override;
    procedure DoBeforeEdit;override;
    procedure DoBeforePost;override;
    procedure DoAfterInsert;override;
    procedure DoAfterPost;override;
    procedure DoAfterDelete;override;
    procedure InternalRefresh;override;
  public
    { Public declarations }
    procedure QueryExecute;
    procedure PrepareQuery;
    procedure EmptyDataSet;
    procedure ClearDataSet;
    procedure CopyFromDataset (pDataset:TDataSet);
    function SortDataset (const pFieldName:String):Boolean;
    procedure LoadFromCSV;
    procedure SaveToCSV;overload;
    procedure SaveToCSV(pDecimaSeparator:Char);overload;
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    //Property needed for master/detail and referential integrity information
    property MasterDataSetTo:TList read FMasterDataSetTo write SetMasterDataSetTo; //for master/detail filtration
    property MasterReferentialKeys:TList read FMasterReferentialKeys write SetMasterReferentialKeys;//for referential integrity
    property SlaveReferentialKeys:TList read FSlaveReferentialKeys write SetSlaveReferentialKeys; //for referential integrity
    property DisableMasterDetailFiltration:Boolean read FDisableMasterDetailFiltration write SetDisableMasterDetailFiltration;
    property OldRecord:{TZMBufDataSet} TBufDataSet read FOldRecord;
  published
    { Published declarations }
    property ZMConnection:TZMConnection read FZMConnection write SetConnection;
    property SQL:TStrings read FSQL write SetSQL;
    property QueryExecuted:Boolean read FQueryExecuted write SetQueryExecuted;
    property TableName:String read FTableName write SetTableName;
    property TableLoaded:Boolean read FTableLoaded write SetTableLoaded;
    property TableSaved:Boolean read FTableSaved write SetTableSaved;
    property PersistentSave:Boolean read FPersistentSave write SetPersistentSave;
    property Parameters: TParams read FParameters write SetParameters;
    //Master/detail information
    property MasterFields: TStrings read FMasterFields write SetMasterFields;
    property MasterSource: TDataSource read FMasterSource  write SetMasterSource;
    //Properties from TBufDataset
    property Filtered;
    Property Active;
    Property FieldDefs;
    Property Fields;
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property OnDeleteError;
    property OnEditError;
    property OnNewRecord;
    property OnPostError;
    property OnFilterRecord;
  end;

procedure Register;

implementation

uses
  ZMReferentialKey;

procedure Register;
begin
  RegisterComponents('ZMSql',[TZMQueryDataSet]);
end;


{ TZMQueryDataSet }

procedure TZMQueryDataSet.SetZMConnection(const AValue: TZMConnection);
begin
  if FZMConnection=AValue then exit;
  FZMConnection:=AValue;
end;

procedure TZMQueryDataSet.SetConnection(const AValue: TZMConnection);
begin
  if FZMConnection=AValue then exit;
  FZMConnection:=AValue;
end;

procedure TZMQueryDataSet.SetDisableMasterDetailFiltration(const AValue: Boolean);
begin
  if FDisableMasterDetailFiltration=AValue then exit;
  FDisableMasterDetailFiltration:=AValue;
end;

procedure TZMQueryDataSet.SetMasterDataSetTo(const AValue: TList);
begin
  if FMasterDataSetTo=AValue then exit;
  FMasterDataSetTo:=AValue;
end;

procedure TZMQueryDataSet.SetMasterReferentialKeys(const AValue: TList);
begin
  if FMasterReferentialKeys=AValue then exit;
  FMasterReferentialKeys:=AValue;
end;

procedure TZMQueryDataSet.SetSlaveReferentialKeys(const AValue: TList);
begin
  if FSlaveReferentialKeys=AValue then exit;
  FSlaveReferentialKeys:=AValue;
end;

procedure TZMQueryDataSet.SetMasterFields(const AValue: TStrings);
begin
  if FMasterFields=AValue then exit;
  FMasterFields.Assign(AValue);
end;

procedure TZMQueryDataSet.SetMasterSource(const AValue: TDataSource);
begin
  if FMasterSource=AValue then exit;

  //Remember old master source
  if Assigned (FMasterSource) then begin
    FOldMasterSource:=FMasterSource;
  end;

  //Ensure filtering
  self.Active:=True; //I am not sure if this is neccessary, but it seems that without that Access violation happens...
  self.Filtered:=True;

  //Set new master data source
  FMasterSource:=AValue;
  UpdateMasterDataSetTo;

end;

procedure TZMQueryDataSet.UpdateMasterDataSetTo;
var
  vAlreadyInList, vToAddNew,vToRemoveOld:Boolean;
begin
  if Assigned (FMasterSource)
     then vAlreadyInList:=(TObject(FMasterSource.DataSet) as TZMQueryDataSet).MasterDataSetTo.IndexOf(self)>=0
     else vAlreadyInList:=False;
  //Inspect how to update detail datasets list
  if ((FOldMasterSource<>FMasterSource) and Assigned(FMasterSource))
     then vToAddNew:=True else vToAddNew:=False;
  if ((FOldMasterSource<>FMasterSource) and (vAlreadyInList=True) and Assigned(FOldMasterSource))
     then vToRemoveOld:=True else vToRemoveOld:=False;
  //Update detail datasets list
  //Append dataset to the list of datasets for which the dataset is master dataset
  if (vToAddNew=True) then begin
    (TObject(FMasterSource.DataSet) as TZMQueryDataSet).MasterDataSetTo.Add(self);
  end;
  //Remove dataset from the list of datasets for which the dataset is master dataset
  if (vToRemoveOld=True)  then begin
    (TObject(FOldMasterSource.DataSet) as TZMQueryDataSet).MasterDataSetTo.Remove(self);
  end;
end;

procedure TZMQueryDataSet.SetParameters(const AValue: TParams);
begin
  if FParameters=AValue then exit;
  FParameters:=AValue;
end;

procedure TZMQueryDataSet.SetPersistentSave(const AValue: Boolean);
begin
  if FPersistentSave=AValue then exit;
  FPersistentSave:=AValue;
end;

procedure TZMQueryDataSet.SetTableLoaded(const AValue: Boolean);
begin
  if FTableLoaded=AValue then exit;
  if AValue=True then
    begin
      try
        LoadFromCSV;
        FTableLoaded:=AValue;
      except
        FTableLoaded:=False;
        self.Active:=False;
      end;
    end;
  if AValue=False then
    begin
      try
        EmptyDataset;
      finally
        FTableLoaded:=AValue;
        self.Active:=False;
      end;
    end;
end;

procedure TZMQueryDataSet.SetTableName(const AValue: String);
begin
  if FTableName=AValue then exit;
  FTableName:=AValue;
end;

procedure TZMQueryDataSet.SetTableSaved(const AValue: Boolean);
begin
  if FTableSaved=AValue then exit;
  if AValue=True then
    begin
      try
        SaveToCSV;
        FTableSaved:=AValue;
      finally
        FTableSaved:=False;
      end;
    end;
  if AValue=False then FTableSaved:=AValue;
end;

procedure TZMQueryDataSet.SetQueryExecuted(const AValue: Boolean);
begin
  if FQueryExecuted=AValue then exit;
  if AValue=True then
    begin
      try
        ZMConnection.Connected:=True;
        QueryExecute;
        FQueryExecuted :=AValue;
      except
        FQueryExecuted :=False;
        self.Active:=False;
      end;
    end;
  if AValue=False then
    begin
      try
        EmptyDataSet;
        ZMConnection.JanSQLInstance.ReleaseRecordset(FRecordsetIndex);
      finally
        FQueryExecuted:=AValue;
        self.Active:=False;
      end;
    end;
end;

procedure TZMQueryDataSet.SetSQL(const AValue: TStrings);
begin
  if FSQL=AValue then exit;
  FSQL.Assign(AValue);
end;

procedure TZMQueryDataSet.PassQueryResult;
begin
  FSourceData:=sdJanSQL;
  FRecordCount:=ZMConnection.JanSQLInstance.RecordSets[FRecordsetIndex].recordcount;
  FFieldCount:=ZMConnection.JanSQLInstance.RecordSets[FRecordsetIndex].fieldcount;
  with self do begin
    Close;
    if InspectFieldDefs then
        begin
          FieldsFromFieldDefs;
        end
      else
        begin
          FieldsFromScratch;
        end;
    Open;
    InsertDataFromJanSQL;
  end;
end;

procedure TZMQueryDataSet.EmptyDataSet;
var
   vFilter:String;
   vFiltered:Boolean;
begin
  with self do begin
    //This is incredible slow in MemDataset, seems to be faster in TBufDataset!
    if Active=False then Open;
    try
      vFilter:=Filter;
      vFiltered:=Filtered;
      Filter:='';
      Filtered:=False;
      First;
      while not EOF do begin
        Delete;
      end;
    finally
      Filter:=vFilter;
      Filtered:=vFiltered;
      Refresh;
    end;
   { //Faster workaround. When in-memory dataset is closed, it is deleted as well...
    Close;
    Open;
    Refresh;  }
  end;
end;

procedure TZMQueryDataSet.ClearDataSet;
//This procedure does not work as expected.
begin
  with self do begin
    if Active=True then Close;
    FieldDefs.Clear;
    Fields.Clear;
  end;
end;

procedure TZMQueryDataSet.CopyFromDataset(pDataset: TDataSet);
var
  vFieldDef:TFieldDef;
  vFieldCount:Integer;
  i,n:Integer;
begin
  vFieldCount:=pDataSet.FieldDefs.Count;
  with self do begin
    try     
	  DisableControls;
	  pDataSet.DisableControls;
	  //Set bulk inbsert flag and suppress master/detail filtration
	  FBulkInsert:=True;
	  self.DisableMasterDetailFiltration:=True;
	  //Reconnect
	  ZMConnection.Disconnect;
	  ZMConnection.Connect;
	  if ZMConnection.Connected=False then ZMConnection.Connected:=True;
	  if self.Active=False then self.Active:=True;
	  self.EmptyDataSet;
      //Let object knows data source...
      FSourceData:=sdOtherDataset;
      FOtherDatasetImport:=pDataset;
      FFieldCount:=FOtherDatasetImport.FieldDefs.Count;
      FRecordCount:=FOtherDatasetImport.RecordCount;
      //Prepare ZMQueryDataset
      with self do begin
	Close;
	if InspectFieldDefs then
	  begin
	    FieldsFromFieldDefs;
	  end
	else
	  begin
	    FieldsFromScratch;
	  end;
	end;
      Open;
      //Insert Fields Data.
      pDataSet.First;
      while not pDataSet.EOF do begin
        Append;
        for n:=0 to vFieldCount-1 do begin
          Fields[n].Value:=pDataSet.Fields[n].Value;
        end;
        Post;
        pDataSet.Next;
      end;
    finally
      FBulkInsert:=False;
      self.DisableMasterDetailFiltration:=True;
      EnableControls;
      pDataset.EnableControls;
    end;
  end;
end;

procedure TZMQueryDataSet.CopyARowFromDataset(pDataset: TDataSet);
var
  vFieldDef:TFieldDef;
  vFieldCount:Integer;
  i,n:Integer;
begin
  vFieldCount:=pDataSet.FieldDefs.Count;
  with self do begin
    try
      //Set bulk insert flag
      FBulkInsert:=True;
      ClearDataSet;
      DisableControls;
      //Create FieldDefs.
      for i:=0 to vFieldCount-1 do begin
        vFieldDef:=FieldDefs.AddFieldDef;
        vFieldDef.Name:=pDataSet.FieldDefs[i].Name;
        vFieldDef.DataType:=pDataSet.FieldDefs[i].DataType;
        vFieldDef.Size:=pDataSet.FieldDefs[i].Size;
        vFieldDef.Required:=pDataSet.FieldDefs[i].Required;
      end;
      MaxIndexesCount:=(2*(self.FieldDefs.Count)+3); 
      {CreateTable;} //In case of TMemDataset ancestor.
      CreateDataSet;  //In case of TBufDataset ancestor.
      Open;
      //Inser current record from pDataSet.
      Append;
      for n:=0 to vFieldCount-1 do begin
        Fields[n].Value:=pDataSet.Fields[n].Value;
      end;
      Post;
    finally
      //Remove bulk inbsert flag
      FBulkInsert:=False;
      EnableControls;
    end;
  end;
end;

procedure TZMQueryDataSet.UpdateFOldRecord;
begin
  //For referential filtration
  if ((self.Active) and (FBulkInsert=False)) then
  begin
    TZMQueryDataSet(FOldRecord).CopyARowFromDataSet(self);
  end;
end;

function TZMQueryDataSet.FormatStringToFloat(pFloatString: string):Double;
{
pFloat string is original string from CSV table or JanSQL resultset.
Since jansql uses dot (".") as decimal separator, all underlying csv tables must be formated with dot (".") as decimal separator.
Result is a float formatted according to current SysUtils.DefaultFormatSettings.DecimalSeparator and SysUtils.DefaultFormatSettings.ThousandSeparator.
These values can be changed by changing ZMConnection.DecimalSeparator property value, which in turn changes SysUtils.DefaultFormatSettings settings.
}
var
  fs:TFormatSettings;
  vFloatString:String;
  vFloatValue:Double;
begin
  fs.DecimalSeparator := SysUtils.DefaultFormatSettings.DecimalSeparator;
  {fs.ThousandSeparator := SysUtils.DefaultFormatSettings.ThousandSeparator;}
  {
  ShowMessage('DecimalSeparator: '+SysUtils.DefaultFormatSettings.DecimalSeparator);
  ShowMessage('ThousandSeparator: '+SysUtils.DefaultFormatSettings.ThousandSeparator);
  }
  case SysUtils.DefaultFormatSettings.DecimalSeparator of
     '.':
       begin
         //Replace decimal separator
         vFloatString:=StringReplace(pFloatString,',','.',[rfReplaceAll, rfIgnoreCase]);
       end;
     ',':
       begin
         //Replace decimal separator
         vFloatString:=StringReplace(pFloatString,'.',',',[rfReplaceAll, rfIgnoreCase]);
       end;
   end;
  vFloatValue:=StrToFloat(vFloatString, fs);
  Result:=vFloatValue;
end;

function TZMQueryDataSet.SortDataset(const pFieldName: String):Boolean;
var
  i: Integer;
  vIndexDefs: TIndexDefs;
  vIndexName: String;
  vIndexOptions: TIndexOptions;
  vField: TField;
begin
  Result := False;
  vField := self.Fields.FindField(pFieldName);
  //If invalid field name, exit.
  if vField = nil then Exit;
  //if invalid field type, exit.
  if {(vField is TObjectField) or} (vField is TBlobField) or
    {(vField is TAggregateField) or} (vField is TVariantField)
     or (vField is TBinaryField) then Exit;
  //Get IndexDefs and IndexName using RTTI
  if IsPublishedProp(self, 'IndexDefs') then
    vIndexDefs := GetObjectProp(self, 'IndexDefs') as TIndexDefs
  else
    Exit;
  if IsPublishedProp(self, 'IndexName') then
    vIndexName := GetStrProp(self, 'IndexName')
  else
    Exit;
  //Ensure IndexDefs is up-to-date
  IndexDefs.Update;
  //If an ascending index is already in use,
  //switch to a descending index
  if vIndexName = pFieldName + '__IdxA'
  then
    begin
      vIndexName := pFieldName + '__IdxD';
      vIndexOptions := [ixDescending];
    end
  else
    begin
      vIndexName := pFieldName + '__IdxA';
      vIndexOptions := [];
    end;
  //Look for existing index
  for i := 0 to Pred(IndexDefs.Count) do
  begin
    if vIndexDefs[i].Name = vIndexName then
      begin
        Result := True;
        Break
      end;  //if
  end; // for
  //If existing index not found, create one
  if not Result then
      begin
        if vIndexName=pFieldName + '__IdxD' then
          self.AddIndex(vIndexName, pFieldName, vIndexOptions, pFieldName)
        else
          self.AddIndex(vIndexName, pFieldName, vIndexOptions);
        Result := True;
      end; // if not
  //Set the index
  SetStrProp(self, 'IndexName', vIndexName);
end;

procedure TZMQueryDataSet.LoadFromCSV;
begin
    self.DisableControls;
  try
    //Set bulk inbsert flag and suppress master/detail filtration
    FBulkInsert:=True;
    self.DisableMasterDetailFiltration:=True;
    //Reconnect
    ZMConnection.Disconnect;
    ZMConnection.Connect;
    if ZMConnection.Connected=False then ZMConnection.Connected:=True;
    if self.Active=False then self.Active:=True;;
    self.EmptyDataSet;
    with FSdfDatasetImport do begin
      Close;
      FileName:=ZMConnection.DatabasePathFull+self.TableName+'.txt';
      FirstLineAsSchema:=True;
      FSdfDatasetImport.Delimiter:=';';
      FSdfDatasetImport.FileMustExist:=False;
      Open;
      //Let object knows data source...
      FSourceData:=sdSdfDataset;
      FFieldCount:=FieldDefs.Count;
      FRecordCount:=RecordCount;
    end;
    //Prepare ZMQueryDataset
    with self do begin
      Close;
      if InspectFieldDefs then
        begin
          FieldsFromFieldDefs;
        end
      else
        begin
          FieldsFromScratch;
        end;
    end;
    Open;
    try
      InsertDataFromCSV;
    finally
      //Persistent save
      if (FPersistentSave=True) then
        begin
          if (FTableName<>null) then self.SaveToCSV
             else ShowMessage('Dataset '+self.Name+' can not be saved because TableName property is not set');
        end;
    end;
  finally
    //Remove bulk inbsert flag and enable master/detail filtration
    FBulkInsert:=False;
    self.DisableMasterDetailFiltration:=False;
    //Refresh self
    self.refresh;
    FSdfDatasetImport.Close;
    self.EnableControls;
  end;
end;

procedure TZMQueryDataSet.SaveToCSV;overload;
var
  vFiltered:Boolean;
  vFilter:String;
  vBookmark:TBookmark;
begin
  try
    self.DisableControls;
    //Disable Master/Detail filtration
    self.DisableMasterDetailFiltration:=True;
    //Get bookmark
    vBookmark:=self.GetBookmark;
    //Get filter
    if self.Filtered=True then vFiltered:=True else vFiltered:=False;
    vFilter:=self.Filter;
    //Temporary disable filters
    self.Filtered:=False;
    //Refresh in order to disable filters
    self.Refresh;
    self.First;
    with FCSVExporterExport do begin
     Dataset:=self;
     FileName:=ZMConnection.DatabasePathFull+self.TableName+'.txt';
     FromCurrent:=False;
     FormatSettings.FieldDelimiter:=';';
     FormatSettings.HeaderRow:=True;
     FormatSettings.QuoteStrings:=[qsAlways];
     FormatSettings.BooleanFalse:='False';
     FormatSettings.BooleanTrue:='True';
     FormatSettings.DateFormat:='yyyy-mm-dd';
     FormatSettings.DateTimeFormat:='yyyy-mm-dd hh:mm:ss';
     {FormatSettings.DecimalSeparator:='.';//Must be dot for sake of compatibility with JanSQL database engine.}
     FormatSettings.DecimalSeparator:=SysUtils.DefaultFormatSettings.DecimalSeparator;
     Execute;
   end;
   //Restore filters.
    self.Filter:=vFilter;
    self.Filtered:=vFiltered;
   //Goto bookmark
   self.GotoBookmark(vBookmark);
  finally
    //Enable Master/Detail filtration
    self.DisableMasterDetailFiltration:=False;
    //Refresh in order to enable filters
    self.Refresh;
    self.FreeBookmark(vBookmark);
    self.EnableControls;
  end;
end;

procedure TZMQueryDataSet.SaveToCSV(pDecimaSeparator: Char);
var
  vFiltered:Boolean;
  vFilter:String;
  vBookmark:TBookmark;
begin
  try
    self.DisableControls;
    //Disable Master/Detail filtration
    self.DisableMasterDetailFiltration:=True;
    //Get bookmark
    vBookmark:=self.GetBookmark;
    //Get filter
    if self.Filtered=True then vFiltered:=True else vFiltered:=False;
    vFilter:=self.Filter;
    //Temporary disable filters
    self.Filtered:=False;
    self.Refresh;
    //Goto first record.
    self.First;
    with FCSVExporterExport do begin
     Dataset:=self;
     FileName:=ZMConnection.DatabasePathFull+self.TableName+'.txt';
     FromCurrent:=False;
     FormatSettings.FieldDelimiter:=';';
     FormatSettings.HeaderRow:=True;
     FormatSettings.QuoteStrings:=[qsAlways];
     FormatSettings.BooleanFalse:='False';
     FormatSettings.BooleanTrue:='True';
     FormatSettings.DateFormat:='yyyy-mm-dd';
     FormatSettings.DateTimeFormat:='yyyy-mm-dd hh:mm:ss';
     FormatSettings.DecimalSeparator:=pDecimaSeparator;
     Execute;
   end;
   //Restore filters.
    self.Filter:=vFilter;
    self.Filtered:=vFiltered;
   //Goto bookmark
   self.GotoBookmark(vBookmark);
  finally
    //Enable Master/Detail filtration
    self.DisableMasterDetailFiltration:=False;
    self.Refresh;
    self.FreeBookmark(vBookmark);
    self.EnableControls;
  end;
end;

procedure TZMQueryDataSet.FieldsFromFieldDefs;
begin
  if Active=False then Open;
  with self do begin
    EmptyDataSet;
    if ((Fields.Count=0) and (FieldDefs.Count>0)) then begin
      self.Close;
      //Set MaxIndexes count if not manually set
      if ((MaxIndexesCount=Null)
         or (MaxIndexesCount<(2*(FieldDefs.Count)+3)))
      then MaxIndexesCount:=(2*(FieldDefs.Count)+3);
      CreateDataset; //Creates Fields from FieldDefs
    end;
    //Set display format for float fields
    SetFloatDisplayFormat;
  end;
end;

procedure TZMQueryDataSet.FieldsFromScratch;
var
   vFieldDef:TFieldDef;
   vCurrentFieldSize, vMaxFieldSize, i, n:Integer;
begin
  with self do begin
    if Active=False then Open;
    EmptyDataset;
    if Active=True then Close;
    ClearDataSet;
    //Create new FieldDefs.
    for n:=0 to FFieldCount-1 do begin
      vFieldDef:=FieldDefs.AddFieldDef;
      case FSourceData of
        sdJanSQL:vFieldDef.Name:=ZMConnection.JanSQLInstance.recordsets[FRecordsetIndex].FieldNames[n];
        sdSdfDataset:vFieldDef.Name:=FSdfDatasetImport.FieldDefs[n].Name;
        sdOtherDataset:vFieldDef.Name:=FOtherDatasetImport.FieldDefs[n].Name;
      end;
      //Determine FieldDef properties
      case FSourceData of
        sdJanSQL:
          begin
            vFieldDef.DataType:=ftString;//TODO: Add other fieldtypes recognition.
            vFieldDef.Required:=False;
            vFieldDef.Precision:=0;
            vFieldDef.Attributes:=[];
          end;
        sdSdfDataset:
          begin
            vFieldDef.DataType:=FSdfDatasetImport.FieldDefs[n].DataType;
            vFieldDef.Required:=False;
            vFieldDef.Precision:=0;
            vFieldDef.Attributes:=[];
          end;
        sdOtherDataset:
          begin
            vFieldDef.DataType:=FOtherDatasetImport.FieldDefs[n].DataType;
            vFieldDef.Required:=FOtherDatasetImport.FieldDefs[n].Required;
            vFieldDef.Precision:=FOtherDatasetImport.FieldDefs[n].Precision;
            vFieldDef.Attributes:=FOtherDatasetImport.FieldDefs[n].Attributes;
          end;
      end;
      //Determine FieldDef.Size property!
      vMaxFieldSize:=0;
      vCurrentFieldSize:=0;
      case FSourceData of
        sdSdfDataset:
          begin
            vFieldDef.Size:=FSdfDatasetImport.Fields[n].Size;
          end;
        sdJanSQL:
          begin
            for i:=0 to FRecordCount-1 do begin
              vCurrentFieldSize:=Length(ZMConnection.JanSQLInstance.RecordSets[FRecordsetIndex].records[i].fields[n].value);
              if vCurrentFieldSize>vMaxFieldSize then vMaxFieldSize:=vCurrentFieldSize;
            end;
            if vMaxFieldSize>0 then vFieldDef.Size:=vMaxFieldSize else vFieldDef.Size:=255;
          end;
        sdOtherDataset:
          begin
            vFieldDef.Size:=FOtherDatasetImport.Fields[n].Size;
          end;
      end;
      //Set MaxIndexes count
      if ((MaxIndexesCount=Null)
        or (MaxIndexesCount<(2*(FieldDefs.Count)+3)))
      then MaxIndexesCount:=(2*(FieldDefs.Count)+3);
    end;
    CreateDataSet;//Creates Fields from FieldDefs
    //Set display format for float fields
    SetFloatDisplayFormat;
  end;
end;

procedure TZMQueryDataSet.EmptySdfDataSet;
begin
  with FSdfDatasetImport do begin
    if Active=False then Open;
    while not EOF do begin
      Delete;
    end;
  end;
end;

procedure TZMQueryDataSet.ClearSdfDataSet;
begin
  with FSdfDatasetImport do begin
    if Active=True then Close;
      FieldDefs.Clear;
      Fields.Clear;
  end;
end;

procedure TZMQueryDataSet.InsertDataFromCSV;
var
   i:integer;
   vFieldString:string;
begin
  if self.Active=False then self.Open;
  if FSdfDatasetImport.Active=False then FSdfDatasetImport.Open;
  FSdfDatasetImport.First;
 while not FSdfDatasetImport.EOF do begin
   self.Append;
   for i:=0 to FFieldCount-1 do begin
     //Fields of Float type require special transformation.
     if self.Fields[i].DataType=ftFloat then
       begin
         vFieldString:=FSdfDatasetImport.Fields[i].AsString;
         try
           self.Fields[i].Value:=FormatStringToFloat(vFieldString);
         except
           self.Fields[i].AsString:=FSdfDatasetImport.Fields[i].AsString;
         end;
       end
     else self.Fields[i].Value:=FSdfDatasetImport.Fields[i].Value;
    end;
   self.Post;
   FSdfDatasetImport.Next;
  end;
 self.Refresh;
 self.First;
end;

procedure TZMQueryDataSet.InsertDataFromJanSQL;
var
   i,n:integer;
   vFieldString:string;
begin
  if self.Active=False then self.Open;
  with self do begin
    for i:=0 to FRecordCount-1 do begin
      Append;
      //Iterate columns
      for n:=0 to FFieldCount-1 do begin
        vFieldString:=ZMConnection.JanSQLInstance.RecordSets[FRecordsetIndex].records[i].fields[n].value;
        if Fields[n].DataType=ftFloat then
          begin
            try
              Fields[n].Value:=FormatStringToFloat(vFieldString);
            except
              Fields[n].AsString:=vFieldString;
            end;
          end
        else Fields[n].Value:=vFieldString;
      end;
      Post;
    end;
    self.Refresh;
    self.First;
  end;
end;

function TZMQueryDataSet.InspectFieldDefs:Boolean;
var
   vNewFieldNames, vOldFieldNames:String;
   i:Integer;
begin
  Result:=False;
  vOldFieldNames:='';
  vNewFieldNames:='';
  for i:=0 to self.FieldDefs.Count-1 do begin
    vOldFieldNames:=vOldFieldNames+self.FieldDefs[i].Name+';';
  end;
  for i:=0 to FFieldCount-1 do begin
    case FSourceData of
      sdJanSQL:vNewFieldNames:=vNewFieldNames+ZMConnection.JanSQLInstance.recordsets[FRecordsetIndex].FieldNames[i]+';';
      sdSdfDataset:vNewFieldNames:=vNewFieldNames+FSdfDatasetImport.FieldDefs[i].Name+';';
      sdOtherDataset:vNewFieldNames:=vNewFieldNames+FOtherDatasetImport.FieldDefs[i].Name+';';
    end;
  end;
  if ((FieldDefs.count>0)
    and (FieldDefs.count=FFieldCount)
    and (vNewFieldNames=vOldFieldNames)) then Result:=True;
end;

procedure TZMQueryDataSet.DoFilterRecord(out Acceptable: Boolean);
var
   i, vCount:Integer;
begin
  //inherited behavior
  //inherited DoFilterRecord(Acceptable);
  //New behavior
  if not Acceptable then exit;
  if ((FBulkInsert=False)
    and (DisableMasterDetailFiltration=False)
    and (Assigned(MasterFields))
    and (Assigned(MasterSource))
    and (Self.Active)
    and (MasterSource.DataSet.Active)) then begin
    vCount:=0;
    self.Filtered:=True; //Ensure dataset is filtered
    for i:=0 to self.MasterFields.Count-1 do begin
      try
       //If Name=Value (Detail field=Master field) pair is provided
       If ((self.FieldByName(MasterFields.Names[i]).Value=MasterSource.DataSet.FieldByName(MasterFields.ValueFromIndex[i]).Value)
            or (self.FieldByName(MasterFields.Names[i]).AsString=MasterSource.DataSet.FieldByName(MasterFields.ValueFromIndex[i]).AsString))
          then Inc(vCount);
      except
        //If Name=Value (Detail field=Master field)  pair is not provided
        If ((self.FieldByName(MasterFields[i]).Value=MasterSource.DataSet.FieldByName(MasterFields[i]).Value)
            or (self.FieldByName(MasterFields[i]).AsString=MasterSource.DataSet.FieldByName(MasterFields[i]).AsString))
          then Inc(vCount);
      end;
    end;
    if vCount=self.MasterFields.Count then Acceptable:=True
      else Acceptable:=False;
    //Refresh slave datasets
    DoAfterScroll;
  end;
end;

procedure TZMQueryDataSet.DoAfterScroll;
var
   i:Integer;
begin
  inherited DoAfterScroll;
  {New behavior}
  //For master/detail filtration
  if Assigned (FMasterDatasetTo) then begin
    for i:=0 to FMasterDatasetTo.Count-1 do begin
      if ((TZMQueryDataSet(FMasterDatasetTo.Items[i]).Active) and (self.Active)
          and (TZMQueryDataSet(FMasterDatasetTo.Items[i]).Fields.Count>0)
          and (self.Fields.Count>0)
          and (TZMQueryDataSet(FMasterDatasetTo.Items[i]).FieldDefs.Count=TZMQueryDataSet(FMasterDatasetTo.Items[i]).Fields.Count)
          and (self.FieldDefs.Count=self.Fields.Count)
          and (TZMQueryDataSet(FMasterDatasetTo.Items[i]).RecordCount>0)
          and (self.RecordCount>0)
          and (DisableMasterDetailFiltration=False)
          and (FBulkInsert=False))
      then begin
        //Detail datasets must be refreshed in order master/detail filtration take effect.
        TZMQueryDataSet(FMasterDatasetTo.Items[i]).Refresh;
        TZMQueryDataSet(FMasterDatasetTo.Items[i]).First;
      end;
    end;
  end;
end;

procedure TZMQueryDataSet.DoBeforeEdit;
begin
  inherited DoBeforeEdit;
  {New behavior}
  //Save OldRecord  
  if FBulkInsert=False then UpdateFOldRecord;
end;

procedure TZMQueryDataSet.DoBeforeInsert;
begin
  inherited DoBeforeInsert;
  {New behavior}
  //Save OldRecord  
  if FBulkInsert=False then UpdateFOldRecord;
end;
 
procedure TZMQueryDataSet.DoBeforeDelete;
var
   SlaveDataSet:TZMQueryDataSet;
   ReferentialKey:TZMReferentialKey;
   ReferentialKind:TZMReferentialKind;
   i,n:Integer;
   vFilter:String;
   vFiltered:Boolean;
   vCount:Integer;
   vDoReferentialDelete:Boolean;
begin
  inherited DoBeforeDelete;
  {New behavior}
  //Save OldRecord  
  if FBulkInsert=False then UpdateFOldRecord;
  //Referential Delete
  if Assigned(FMasterReferentialKeys) then begin
    for i:=0 to FMasterReferentialKeys.Count-1 do begin
      ReferentialKey:=TObject(FMasterReferentialKeys[i]) as TZMReferentialKey;
      SlaveDataSet:=ReferentialKey.SlaveDataSet;
      ReferentialKind:=ReferentialKey.ReferentialKind;
      if ((SlaveDataSet.Active) and (Self.Active)
         and (ReferentialKey.Enabled=True)
         and (SlaveDataSet.Fields.Count>0) and (SlaveDataSet.FieldDefs.Count=SlaveDataSet.Fields.Count)
         and (self.FieldDefs.Count>0) and (self.FieldDefs.Count=self.Fields.Count)
         and (ReferentialKey.Enabled=True)
         and Assigned(ReferentialKey.JoinedFields)
         and (rkDelete in ReferentialKind)) then begin
        try
          SlaveDataSet.DisableControls;
          //Enforce referential delete. self=MasterDataset
          try
            //Delete records in SlaveDataset
            begin
              try
                vFilter:=SlaveDataSet.Filter;
                vFiltered:=SlaveDataSet.Filtered;
                //Disable DoFilterRecord
                SlaveDataSet.DisableMasterDetailFiltration:=True;
                SlaveDataSet.Filtered:=False;
                //Iterate through records in SlaveDataSet and update every record.
                SlaveDataSet.Refresh;
                SlaveDataSet.First;
                while not SlaveDataSet.EOF do begin
                  //Inspect whether referential conditions are met
                  vCount:=0;
                  vDoReferentialDelete:=False;
                  for n:=0 to ReferentialKey.JoinedFields.Count-1 do begin
                    try
                      //If MasterField=SlaveField pair is provided in JoinedFields item.
                      if SlaveDataSet.FieldByName(ReferentialKey.JoinedFields.Names[n]).AsString
                        =self.FOldRecord.FieldByName(ReferentialKey.JoinedFields.ValueFromIndex[n]).AsString
                        then Inc(vCount);
                    except
                      //If MasterField=SlaveField pair is not provided in JoinedFields item.
                      if SlaveDataSet.FieldByName(ReferentialKey.JoinedFields.Names[n]).AsString
                        =self.FOldRecord.FieldByName(ReferentialKey.JoinedFields[n]).AsString
                        then Inc(vCount);
                    end;
                    if vCount=ReferentialKey.JoinedFields.Count then vDoReferentialDelete:=True;
                  end;
                  //Do referential delete
                  if vDoReferentialDelete=True then SlaveDataSet.Delete
                  else SlaveDataSet.Next;
                end;
              finally
                //Enable DoFilterRecord
                SlaveDataSet.DisableMasterDetailFiltration:=False;
                SlaveDataSet.Filter:=vFilter;
                SlaveDataSet.Filtered:=vFiltered;
              end;
            end;
          finally
            SlaveDataSet.Refresh;
          end;
        finally
          SlaveDataSet.EnableControls;
        end;
      end;
    end;
  end;
end;

procedure TZMQueryDataSet.DoBeforePost;
begin
  inherited DoBeforePost;
  {New behavior}
  if self.State=dsEdit then FDoReferentialUpdate:=True
    else FDoReferentialUpdate:=False;
end;

procedure TZMQueryDataSet.DoAfterInsert;
var
   MasterDataSet:TZMQueryDataSet;
   ReferentialKey:TZMReferentialKey;
   ReferentialKind:TZMReferentialKind;
   i,n:Integer;
begin
  inherited DoAfterInsert;
  //Referential Insert - SlaveDataset
  if Assigned(FSlaveReferentialKeys) then begin
    for i:=0 to FSlaveReferentialKeys.Count-1 do begin
      ReferentialKey:=TObject(FSlaveReferentialKeys[i]) as TZMReferentialKey;
      MasterDataSet:=ReferentialKey.MasterDataSet;
      ReferentialKind:=ReferentialKey.ReferentialKind;
      if ((MasterDataSet.Active) and (Self.Active)
           and (MasterDataSet.FieldDefs.Count>0) and (MasterDataSet.FieldDefs.Count=MasterDataSet.Fields.Count)
           and (self.Fields.Count>0) and (self.FieldDefs.Count=self.Fields.Count)
           and (ReferentialKey.Enabled=True)
           and Assigned(ReferentialKey.JoinedFields)
           and (rkInsert in ReferentialKind)
           and (FBulkInsert=False))
      then begin
        //Enforce referential insert for self as SlaveDataSet
        try
          self.DisableControls;
          for n:=0 to ReferentialKey.JoinedFields.Count-1 do begin
             try
               //If MasterField=SlaveField pair is provided in JoinedFields item.
               self.FieldByName(ReferentialKey.JoinedFields.Names[n]).Value:=MasterDataSet.FieldByName(ReferentialKey.JoinedFields.ValueFromIndex[n]).Value;
             except
               //If MasterField=SlaveField pair is not provided in JoinedFields item.
               self.FieldByName(ReferentialKey.JoinedFields[n]).Value:=MasterDataSet.FieldByName(ReferentialKey.JoinedFields[n]).Value;
             end;
          end;
        finally
          self.EnableControls;
        end;
      end;
    end;
  end;
  //Refresh slave datasets
  DoAfterScroll;
end;

procedure TZMQueryDataSet.DoAfterPost;
var
   {MasterDataSet:TZMQueryDataSet;}
   SlaveDataSet:TZMQueryDataSet;
   ReferentialKey:TZMReferentialKey;
   ReferentialKind:TZMReferentialKind;
   i,n:Integer;
   vFilter:String;
   vFiltered:Boolean;
   vCount:Integer;
   vDoReferentialUpdate:Boolean;
begin
  inherited DoAfterPost;
  {New behavior}
  //Persistent save
  if ((FPersistentSave=True) and (FBulkInsert=False)) then
    begin
      if (FTableName<>null) then self.SaveToCSV
         else ShowMessage('Dataset can not be saved because TableName property is not set');
    end;
  if FDoReferentialUpdate=False then exit;
  //Referential Update; self as Master Dataset
  if Assigned(FMasterReferentialKeys) then begin
    for i:=0 to FMasterReferentialKeys.Count-1 do begin
      ReferentialKey:=TObject(FMasterReferentialKeys[i]) as TZMReferentialKey;
      SlaveDataSet:=ReferentialKey.SlaveDataSet;
      ReferentialKind:=ReferentialKey.ReferentialKind;
      if ((SlaveDataSet.Active) and (Self.Active)
           and (SlaveDataSet.FieldDefs.Count>0) and (SlaveDataSet.FieldDefs.Count=SlaveDataSet.Fields.Count)
           and (self.Fields.Count>0) and (self.FieldDefs.Count=self.Fields.Count)
           and (ReferentialKey.Enabled=True)
           and Assigned(ReferentialKey.JoinedFields)
           and (rkUpdate in ReferentialKind)
           and (FBulkInsert=False))
      then begin
        try
          //Update records in SlaveDataset
          SlaveDataSet.DisableControls;
          begin
            try
              vFilter:=SlaveDataSet.Filter;
              vFiltered:=SlaveDataSet.Filtered;
              //Disable DoFilterRecord
              SlaveDataSet.DisableMasterDetailFiltration:=True;
              SlaveDataSet.Filtered:=False;
              //Iterate through records in SlaveDataSet and update every record.
              SlaveDataSet.Refresh;
              SlaveDataSet.First;
              while not SlaveDataSet.EOF do begin
                //Inspect whether referential conditions are met
                vCount:=0;
                vDoReferentialUpdate:=False;
                for n:=0 to ReferentialKey.JoinedFields.Count-1 do begin
                  try
                    //If MasterField=SlaveField pair is provided in JoinedFields item.
                    if SlaveDataSet.FieldByName(ReferentialKey.JoinedFields.Names[n]).AsString
                      =self.FOldRecord.FieldByName(ReferentialKey.JoinedFields.ValueFromIndex[n]).AsString
                      then Inc(vCount);
                  except
                    //If MasterField=SlaveField pair is not provided in JoinedFields item.
                    if SlaveDataSet.FieldByName(ReferentialKey.JoinedFields.Names[n]).AsString
                      =self.FOldRecord.FieldByName(ReferentialKey.JoinedFields[n]).AsString
                      then Inc(vCount);
                  end;
                  if vCount=ReferentialKey.JoinedFields.Count then vDoReferentialUpdate:=True;
                end;
                //Do referential update
                if vDoReferentialUpdate=True then begin
                  SlaveDataSet.Edit;
                  //Enforce referential insert/update for self as SlaveDataSet
		  for n:=0 to ReferentialKey.JoinedFields.Count-1 do begin
                    try
    		      //If MasterField=SlaveField pair is provided in JoinedFields item.
    		      SlaveDataSet.FieldByName(ReferentialKey.JoinedFields.Names[n]).Value
                        :=self.FieldByName(ReferentialKey.JoinedFields.ValueFromIndex[n]).Value;
    		    except
    		      //If MasterField=SlaveField pair is not provided in JoinedFields item.
    		      SlaveDataSet.FieldByName(ReferentialKey.JoinedFields[n]).Value
                        :=self.FieldByName(ReferentialKey.JoinedFields[n]).Value;
    		    end;
                  end;
                  SlaveDataSet.Post;
                end;
                SlaveDataSet.Next;
              end;
            finally
              //Enable DoFilterRecord
              SlaveDataSet.DisableMasterDetailFiltration:=False;
              SlaveDataSet.Filter:=vFilter;
              SlaveDataSet.Filtered:=vFiltered;
            end;
          end;
        finally
          SlaveDataSet.Refresh;
          SlaveDataSet.EnableControls;
        end;
      end;
    end;
  end;
  //Refresh slave datasets
  DoAfterScroll;
end;

procedure TZMQueryDataSet.DoAfterDelete;
begin
  inherited DoAfterDelete;
  {New behavior}
  //Persistent save
  if ((FPersistentSave=True) and (FBulkInsert=False)) then
    begin
      if (FTableName<>null) then self.SaveToCSV
         else ShowMessage('Dataset can not be saved because TableName property is not set');
    end;
  //Refresh slave datasets
  DoAfterScroll;
end;

procedure TZMQueryDataSet.InternalRefresh;
begin
 //Do nothing. TBufDataSet's InternalRefresh does troubles.
 //It seems that what in TDataSet's Refresh method is implemented is quite enough for ZMQueryDataset.
 {
 inherited InternalRefresh;
 }
end;

procedure TZMQueryDataSet.QueryExecute;
begin
  try
    self.DisableControls;
    //Set bulk inbsert flag and suppress master/detail filtration
    FBulkInsert:=True;
    self.DisableMasterDetailFiltration:=True;
    //Reconnect
    ZMConnection.Disconnect;
    ZMConnection.Connect;
    if ZMConnection.Connected=False then ZMConnection.Connected:=True;
    if self.Active=False then Open;
    EmptyDataSet;
    //Prepare SQL string
    PrepareQuery;
    //Execute query in JanSQL engine
    try
      FRecordsetIndex:=0;
      FRecordsetIndex:=ZMConnection.JanSQLInstance.SQLDirect(FPreparedSQL);
    except
      ShowMessage ('Error while trying to execute query.'
         +ZMConnection.JanSQLInstance.Error);
    end;
    //If there is a resultset, pass it to ZMQueryDataSet.
    if FRecordsetIndex>0 then
      begin
        try
          try
            //Load query result into zmquerydataset
            PassQueryResult;
          finally
            //Persistent save
            if (FPersistentSave=True) then
              begin
                if (FTableName<>null) then self.SaveToCSV
                   else ShowMessage('Dataset '+self.Name+' can not be saved because TableName property is not set');
              end;
          end;
        finally
          ZMConnection.JanSQLInstance.ReleaseRecordset(FRecordsetIndex);
        end;
      end;
  finally
    self.EnableControls;
    //Remove bulk insert flag and enable master/detail filtration
    FBulkInsert:=False;
    self.DisableMasterDetailFiltration:=False;
    //Refresh self
    self.refresh;
  end;
end;

procedure TZMQueryDataSet.PrepareQuery;
{This is temporary simple solution of passing parameters to query SQL string before execution}
var
   i:Integer;
begin
  FOriginalSQL:='';
  FPreparedSQL:='';
  for i:=0 to FSQL.Count-1 do begin
    FOriginalSQL:=FOriginalSQL+' '+FSQL.Strings[i];
  end;
  FPreparedSQL:=FOriginalSQL;
  if (Assigned(self.Parameters) and (self.Parameters.Count>0)) then begin
     for i:=0 to self.Parameters.Count-1 do begin
       //Apply parameters by name
       FPreparedSQL:=AnsiReplaceText(FPreparedSQL,':'+self.Parameters[i].Name,self.Parameters[i].Value);//There must be better way...
     end;
  end;
  {ShowMessage('Prepared query:'+FPreparedSQL);}
end;

constructor TZMQueryDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //SQL
  FSQL := TStringList.Create;
  //Master/detail filtration
  FMasterFields:=TStringList.Create;
  FMasterDataSetTo:=TList.Create;
  //Referential integrity
  FMasterReferentialKeys:=TList.Create;
  FSlaveReferentialKeys:=TList.Create;
  //Import/export
  FSdfDatasetImport:=TSdfDataset.Create(nil);
  FCSVExporterExport:=TCSVExporter.Create(nil);
  //Parameters
  FParameters:=TParams.Create;
  //FOldRecord
  FOldRecord:={TZMBufDataSet}TBufDataSet.Create(nil);
end;

destructor TZMQueryDataSet.Destroy;
begin
  //Check persistency
  if FPersistentSave=True then
    begin
      if (FTableName<>null) then self.SaveToCSV
         else ShowMessage('Dataset can not be saved because TableName property is not set');
    end;
  //SQL
  FSQL.Free;
  //Master/detail
  FMasterFields.Free;
  FMasterDataSetTo.Free;
  //Referential integrity
  FMasterReferentialKeys.Free;
  FSlaveReferentialKeys.Free;
  //Import/Export
  FSdfDatasetImport.Close;
  FSdfDatasetImport.Free;
  FCSVExporterExport.Free;
  //Parameters
  FParameters.Free;
  //FOldRecord
  FOldRecord.Free;
  //JanSQL
  if FRecordsetIndex>0 then ZMConnection.JanSQLInstance.ReleaseRecordset(FRecordsetIndex);
  //inherited
  inherited Destroy;
end;


procedure TZMQueryDataSet.SetFloatDisplayFormat;
var J:Integer;
begin
  //If FloatDisplayFormat property is set, then take it...
  if ((FZMConnection.FloatDisplayFormat<>'')
    and (FZMConnection.FloatDisplayFormat<>Null)) then begin
    //Set display format for Float type
    for J:=0 to self.FieldDefs.Count-1 do begin
      if self.FieldDefs[J].DataType=ftFloat
        then begin
          (self.Fields[J] as TFloatField).DisplayFormat
            :=FZMConnection.FloatDisplayFormat;
        end;
    end;
  end;
end;

initialization
{$I zmquerydataset.lrs}

end.
