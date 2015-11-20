unit kantu_singleSystem;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, kantu_definitions, kantu_simulation, kantu_indicators;

type

  { TSingleSystem }

  TSingleSystem = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button6: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    SymbolsCombo: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    EditHourFilter: TEdit;
    EditDayFilter: TEdit;
    EditSL: TEdit;
    EditTP: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    RulesList: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { private declarations }
  public
    patternToUse : TIndicatorPattern;
    closingPatternToUse: TIndicatorPattern;
    { public declarations }
  end;

var
  SingleSystem: TSingleSystem;

implementation

uses kantu_main;

{$R *.lfm}

{ TSingleSystem }

procedure TSingleSystem.Button1Click(Sender: TObject);
var
  i: integer;
begin
       if (ComboBox1.ItemIndex >= 0) and (ComboBox2.ItemIndex >= 0) then
       begin
            RulesList.Items.Add('Go long (short opposite) ' + ComboBox1.Items[ComboBox1.ItemIndex] + '[' +Edit1.Text+ ']' + ' > ' + ComboBox2.Items[ComboBox2.ItemIndex] + '[' +Edit2.Text+ ']' );


            SetLength(patternToUse.tradingRules, Length(patternToUse.tradingRules)+1) ;

            i := Length(patternToUse.tradingRules)-1 ;

            SetLength(patternToUse.tradingRules[i], INDICATOR_RULES_TOTAL);

            patternToUse.tradingRules[i][IDX_SIZE_COMPARISON]  := 0;
            patternToUse.tradingRules[i][IDX_LOGIC_TYPE]  := LOGIC_AND;

            patternToUse.tradingRules[i][IDX_FIRST_INDICATOR_SHIFT]    := StrToInt(Edit1.Text)-1;
            patternToUse.tradingRules[i][IDX_SECOND_INDICATOR_SHIFT]    := StrToInt(Edit2.Text)-1;

            patternToUse.tradingRules[i][IDX_FIRST_INDICATOR]  := ComboBox1.ItemIndex;
            patternToUse.tradingRules[i][IDX_SECOND_INDICATOR] := ComboBox2.ItemIndex;

       end;


end;

procedure TSingleSystem.Button2Click(Sender: TObject);
begin
       RulesList.Clear;
       SetLength(patternToUse.tradingRules, 0);
end;

procedure TSingleSystem.Button3Click(Sender: TObject);
begin

  if MainForm.isDataLoaded = false then
  Exit;

  patternToUse.allowLongSignals:= true;
  patternToUse.allowShortSignals:= true;

  if SymbolsCombo.ItemIndex < 0 then
  begin
       ShowMessage('Please select a symbol from the dropdown menu to run the simulation.') ;
       Exit;
  end;

  if EditSL.Text <> '' then
  begin
  patternToUse.SL := StrToFloat(EditSL.Text) ;
  SimulationForm.UseSLCheck.Checked := true;
  end else begin
  SimulationForm.UseSLCheck.Checked := false;
  patternToUse.SL := 2.0;
  end;

  if EditTP.Text <> '' then
  begin
  patternToUse.TP := StrToFloat(EditTP.Text) ;
  SimulationForm.UseTPCheck.Checked := true;
  end else begin
  SimulationForm.UseTPCheck.Checked := false;
  end;

  if EditHourFilter.Text <> '' then
  begin
  SimulationForm.UseHourFilter.Checked := true;
  patternToUse.hourFilter := StrToInt(EditHourFilter.Text) ;
  closingPatternToUse.hourFilter := StrToInt(EditHourFilter.Text) ;
  end else
  SimulationForm.UseHourFilter.Checked  := false;

  if EditDayFilter.Text <> '' then
  begin
  SimulationForm.UseDayFilter.Checked := true;
  patternToUse.dayFilter := StrToInt(EditDayFilter.Text) ;
  closingPatternToUse.dayFilter := StrToInt(EditDayFilter.Text) ;
  end else
  SimulationForm.UseDayFilter.Checked  := false;

  runSingleSystem(SymbolsCombo.ItemIndex, patternToUse, closingPatternToUse);
end;

procedure TSingleSystem.Button4Click(Sender: TObject);
var
  i: integer;
begin


end;

procedure TSingleSystem.Button6Click(Sender: TObject);
var
  i,j: integer;
  selectedForDelete: integer;
  patternTempCopy: TIndicatorPattern;
begin

     for i:= 0 to RulesList.Count-1 do
     begin

       if RulesList.Selected[i] then
       selectedForDelete := i;

     end;



     j := 0;

     SetLength(patternTempCopy.tradingRules, 0);

     for i:= 0 to Length(patternToUse.tradingRules)-1 do
     begin
            if i <> selectedForDelete then
            begin

                 SetLength(patternTempCopy.tradingRules, Length(patternTempCopy.tradingRules)+1);

                 j :=  Length(patternTempCopy.tradingRules)-1 ;

                 SetLength(patternTempCopy.tradingRules[j], INDICATOR_RULES_TOTAL);

                 patternTempCopy.tradingRules[j][IDX_SIZE_COMPARISON]  := patternToUse.tradingRules[i][IDX_SIZE_COMPARISON];
                 patternTempCopy.tradingRules[j][IDX_LOGIC_TYPE]  :=patternToUse.tradingRules[i][IDX_LOGIC_TYPE];

                 patternTempCopy.tradingRules[j][IDX_FIRST_INDICATOR_SHIFT]    := patternToUse.tradingRules[i][IDX_FIRST_INDICATOR_SHIFT];
                 patternTempCopy.tradingRules[j][IDX_SECOND_INDICATOR_SHIFT]    := patternToUse.tradingRules[i][IDX_SECOND_INDICATOR_SHIFT];

                 patternTempCopy.tradingRules[j][IDX_FIRST_INDICATOR]  := patternToUse.tradingRules[i][IDX_FIRST_INDICATOR];
                 patternTempCopy.tradingRules[j][IDX_SECOND_INDICATOR] := patternToUse.tradingRules[i][IDX_SECOND_INDICATOR];

            end;
     end;

     SetLength(patternToUse.tradingRules, 0);
     SetLength(patternToUse.tradingRules, Length(patternTempCopy.tradingRules));

     for i:= 0 to Length(patternToUse.tradingRules)-1 do
     begin
          SetLength(patternToUse.tradingRules[i], INDICATOR_RULES_TOTAL);

          patternToUse.tradingRules[i][IDX_SIZE_COMPARISON]  := patternTempCopy.tradingRules[i][IDX_SIZE_COMPARISON];
          patternToUse.tradingRules[i][IDX_LOGIC_TYPE]  :=patternTempCopy.tradingRules[i][IDX_LOGIC_TYPE];

          patternToUse.tradingRules[i][IDX_FIRST_INDICATOR_SHIFT]    := patternTempCopy.tradingRules[i][IDX_FIRST_INDICATOR_SHIFT];
          patternToUse.tradingRules[i][IDX_SECOND_INDICATOR_SHIFT]    := patternTempCopy.tradingRules[i][IDX_SECOND_INDICATOR_SHIFT];

          patternToUse.tradingRules[i][IDX_FIRST_INDICATOR]  := patternTempCopy.tradingRules[i][IDX_FIRST_INDICATOR];
          patternToUse.tradingRules[i][IDX_SECOND_INDICATOR] := patternTempCopy.tradingRules[i][IDX_SECOND_INDICATOR];
     end;



     RulesList.Items.Delete(selectedForDelete);



end;




end.

