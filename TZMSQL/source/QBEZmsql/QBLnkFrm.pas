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

unit QBLnkFrm;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}



interface

uses
  Forms,
  StdCtrls, ExtCtrls;

type
  TOQBLinkForm = class(TForm)
    RadioOpt: TRadioGroup;
    RadioType: TRadioGroup;
    BtnOk: TButton;
    BtnCancel: TButton;
    txtTable1: TStaticText;
    txtTable2: TStaticText;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    txtCol1: TStaticText;
    Label4: TLabel;
    txtCol2: TStaticText;
  end;

implementation

  {$R *.lfm}

end.