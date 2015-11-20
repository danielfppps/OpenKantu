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

Last Modified: 28.01.2014

Known Issues:

History (Change log):global history log is in ZMQueryDataset unit.
-----------------------------------------------------------------------------}
unit ZMReferentialKey;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  {$IFDEF UNIX} clocale, cwstring,{$ENDIF}
  ZMQueryDataSet;

type

  TZMReferentialKind=set of (rkInsert, rkUpdate, rkDelete);

  { TZMReferentialKey }

  TZMReferentialKey = class(TComponent)
  private
    FEnabled: Boolean;
    FJoinedFields: TStrings;
    FMasterDataSet: TZMQueryDataSet;
    FOldMasterDataSet: TZMQueryDataSet;
    FReferentialKind: TZMReferentialKind;
    FSlaveDataSet: TZMQueryDataSet;
    FOldSlaveDataSet: TZMQueryDataSet;
    procedure SetEnabled(const AValue: Boolean);
    procedure SetJoinedFields(const AValue: TStrings);
    procedure SetReferentialKind(const AValue: TZMReferentialKind);
    procedure SetMasterDataSet(const AValue: TZMQueryDataSet);
    procedure SetSlaveDataSet(const AValue: TZMQueryDataSet);
    { Private declarations }
    procedure UpdateReferentialKeys;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
  published
    { Published declarations }
    property MasterDataSet:TZMQueryDataSet read FMasterDataSet write SetMasterDataSet;
    property SlaveDataSet:TZMQueryDataSet read FSlaveDataSet write SetSlaveDataSet;
    property ReferentialKind: TZMReferentialKind read FReferentialKind write SetReferentialKind;
    property JoinedFields:TStrings read FJoinedFields write SetJoinedFields;
    property Enabled:Boolean read FEnabled write SetEnabled;
  end;

implementation

{ TZMReferentialKey }

procedure TZMReferentialKey.SetJoinedFields(const AValue: TStrings);
begin
  if FJoinedFields=AValue then exit;
  FJoinedFields.Assign(AValue);
end;

procedure TZMReferentialKey.SetEnabled(const AValue: Boolean);
begin
  if FEnabled=AValue then exit;
  FEnabled:=AValue;
end;

procedure TZMReferentialKey.SetReferentialKind(const AValue: TZMReferentialKind);
begin
  if FReferentialKind=AValue then exit;
  FReferentialKind:=AValue;
end;

procedure TZMReferentialKey.SetMasterDataSet(const AValue: TZMQueryDataSet);
begin
  if FMasterDataSet=AValue then exit;
  if Assigned (FMasterDataSet) then FOldMasterDataSet:=FMasterDataSet;
  FMasterDataSet:=AValue;
  //Update referential integrity.
  UpdateReferentialKeys;
end;

procedure TZMReferentialKey.SetSlaveDataSet(const AValue: TZMQueryDataSet);
begin
  if FSlaveDataSet=AValue then exit;
  if Assigned(FSlaveDataSet) then FOldSlaveDataSet:=FSlaveDataSet;
  FSlaveDataSet:=AValue;
  //Update referential integrity.
  UpdateReferentialKeys;
end;

constructor TZMReferentialKey.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FJoinedFields:=TStringList.Create;
end;

destructor TZMReferentialKey.Destroy;
begin
  FreeAndNil(FJoinedFields);
  inherited Destroy;
end;

procedure TZMReferentialKey.UpdateReferentialKeys;
var
  vToAddNewMaster,vToAddNewSlave,
    vToRemoveOldMaster, vToRemoveOldSlave,
      vAlreadyInListMaster, vAlreadyInListSlave:Boolean;
begin
  if Assigned(MasterDataSet)
        then vAlreadyInListMaster:=MasterDataSet.MasterReferentialKeys.IndexOf(self)>=0
        else vAlreadyInListMaster:=False;
  if Assigned(SlaveDataSet)
        then vAlreadyInListSlave:=SlaveDataSet.SlaveReferentialKeys.IndexOf(self)>=0
        else vAlreadyInListSlave:=False;
  //Inspect how to update list
  //Add new item into list?
  if ((vAlreadyInListMaster=False) and Assigned(MasterDataSet) and Assigned(SlaveDataSet))
	then vToAddNewMaster:=True else vToAddNewMaster:=False;
  if ((vAlreadyInListSlave=False) and Assigned(MasterDataSet) and Assigned(SlaveDataSet))
	then vToAddNewSlave:=True else vToAddNewSlave:=False;
  //Remove existing item from the list?
  if ((FOldMasterDataSet<>MasterDataSet) and (vAlreadyInListMaster=True)
     and Assigned(FOldMasterDataSet))
        then vToRemoveOldMaster:=True else vToRemoveOldMaster:=False;
  if ((FOldSlaveDataSet<>SlaveDataSet) and (vAlreadyInListSlave=True)
     and Assigned(FOldSlaveDataSet))
        then vToRemoveOldSlave:=True else vToRemoveOldSlave:=False;
  //Update lists
  //Append referential key to datasets
  if (vToAddNewMaster=True) then
    MasterDataSet.MasterReferentialKeys.Add(self);
  if (vToAddNewSlave=True) then
      SlaveDataSet.SlaveReferentialKeys.Add(self);
  //Remove referential key from datasets
  if (vToRemoveOldMaster=True)  then
    MasterDataSet.MasterReferentialKeys.Remove(self);
  if (vToRemoveOldSlave=True)  then
    SlaveDataSet.SlaveReferentialKeys.Remove(self);
end;

end.
