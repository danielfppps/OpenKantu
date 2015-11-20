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

unit QBAbout;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}



interface

uses
  Forms,
  StdCtrls, ExtCtrls, LMessages, LCLType;

type
  TOQBAboutForm = class(TForm)
    Bevel1: TBevel;
    Ok: TButton;
    Label1: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label2: TLabel;
    procedure WMNCHitTest(var Message :TLMNCHITTEST); message LM_NCHITTEST;
  end;

implementation

  {$R *.lfm}

procedure TOQBAboutForm.WMNCHitTest(var Message: TLMNCHITTEST);
begin
  inherited;
  if Message.Result = htClient then
    Message.Result := htCaption;
end;

end.
