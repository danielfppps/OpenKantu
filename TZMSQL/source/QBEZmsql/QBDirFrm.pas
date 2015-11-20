{*******************************************************}
{                                                       }
{       Delphi Visual Component Library                 }
{       QBuilder dialog component                       }
{                                                       }
{       Copyright (c) 1996-2003 Sergey Orlik            }
{                                                       }
{     Written by:                                       }
{       Sergey Orlik                                    }
{       product manager                                 }
{       Russia, C.I.S. and Baltic States (former USSR)  }
{       Borland Moscow office                           }
{       Internet:  support@fast-report.com,             }
{                  sorlik@borland.com                   }
{                  http://www.fast-report.com           }
{                                                       }
{ Converted to Lazarus/Free Pascal by Jean Patrick      }
{ Data: 14/02/2013                                      }
{ E-mail: jpsoft-sac-pa@hotmail.com                     }
{                                                       }
{*******************************************************}

unit QBDirFrm;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}



interface

uses
  Forms,
  StdCtrls, ExtCtrls, FileCtrl, EditBtn;

type

  { TOQBDirForm }

  TOQBDirForm = class(TForm)
    BtnOk: TButton;
    BtnCancel: TButton;
    Bevel: TBevel;
    DirLbx: TDirectoryEdit;
    FileLbx: TFileListBox;
    procedure DirLbxChange(Sender: TObject);
  private
    procedure SetDir(aDir: string);
    function GetDir: string;
  public
    property Directory: string read GetDir write SetDir;
  end;


implementation

  {$R *.lfm}

procedure TOQBDirForm.SetDir(aDir: string);
begin
  DirLbx.Directory := aDir;
end;

function TOQBDirForm.GetDir: string;
begin
  Result := DirLbx.Directory;
end;

procedure TOQBDirForm.DirLbxChange(Sender: TObject);
begin
  FileLbx.Directory := DirLbx.Directory;
end;

end.