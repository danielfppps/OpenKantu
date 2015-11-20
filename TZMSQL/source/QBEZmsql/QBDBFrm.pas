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

unit QBDBFrm;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}



interface

uses
  Controls, Forms,
  StdCtrls, ExtCtrls;

type
  TOQBDBForm = class(TForm)
    BtnOk: TButton;
    BtnCancel: TButton;
    Bevel1: TBevel;
    ComboDB: TComboBox;
    CheckDB: TCheckBox;
    EdtDir: TEdit;
    btnDir: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure btnDirClick(Sender: TObject);
  end;


implementation

  {$R *.lfm}

uses
  QBDirFrm;


procedure TOQBDBForm.btnDirClick(Sender: TObject);
var
  QBDirForm: TOQBDirForm;
  s: string;
begin
  s := '';
  QBDirForm := TOQBDirForm.Create(Application);
  GetDir(0, s);
  QBDirForm.Directory := s;
  if QBDirForm.ShowModal = mrOk then
    EdtDir.Text := QBDirForm.Directory;
  QBDirForm.Free;
end;

end.