unit kantu_simulation_show;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids, ExtDlgs, CheckLst, kantu_simulation, kantu_definitions;

type

  { TSimulationForm2 }

  TSimulationForm2 = class(TForm)
    AsymmetryCheck: TCheckBox;
    BeginInSampleCalendar: TCalendarDialog;
    BeginInSampleEdit: TEdit;
    Button1: TButton;
    FixComplexityCheck: TCheckBox;
    LROriginCheck: TCheckBox;
    Label3: TLabel;
    OptionsGrid: TStringGrid;
    OptionsPanel: TPanel;
    UseAlwaysUpTLCheck: TCheckBox;
    UseClosingPatternCheck: TCheckBox;
    UseDayFilter: TCheckBox;
    UsedInputsList: TCheckListBox;
    EndInSampleCalendar: TCalendarDialog;
    EndInSampleEdit: TEdit;
    EndOutOfSampleCalendar: TCalendarDialog;
    EndOutOfSampleEdit: TEdit;
    Label1: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label2: TLabel;
    OptTargetComboBox: TComboBox;
    UseFixedHour: TCheckBox;
    UseFixedSLTP: TCheckBox;
    UseHourFilter: TCheckBox;
    UseSLCheck: TCheckBox;
    UseTimeExit: TCheckBox;
    UseTPCheck: TCheckBox;
    procedure AsymmetryCheckChange(Sender: TObject);
    procedure BeginInSampleCalendarDayChanged(Sender: TObject);
    procedure BeginInSampleEditChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure EndOutOfSampleEditChange(Sender: TObject);
    procedure UseAlwaysUpTLCheckChange(Sender: TObject);
    procedure UsedInputsListClickCheck(Sender: TObject);
    procedure UseFixedHourChange(Sender: TObject);
    procedure UseFixedSLTPChange(Sender: TObject);
    procedure EndInSampleCalendarDayChanged(Sender: TObject);
    procedure EndOutOfSampleCalendarDayChanged(Sender: TObject);
    procedure FixComplexityCheckChange(Sender: TObject);
    procedure LROriginCheckChange(Sender: TObject);
    procedure OptionsGridEditingDone(Sender: TObject);
    procedure OptTargetComboBoxChange(Sender: TObject);
    procedure UseDayFilterChange(Sender: TObject);
    procedure UseHourFilterChange(Sender: TObject);
    procedure UseSLCheckChange(Sender: TObject);
    procedure UseTimeExitChange(Sender: TObject);
    procedure UseTPCheckChange(Sender: TObject);
    procedure BeginInSampleEditClick(Sender: TObject);
    procedure EndInSampleEditClick(Sender: TObject);
    procedure EndOutOfSampleEditClick(Sender: TObject);
    procedure OptionsGridPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  SimulationForm2: TSimulationForm2;

implementation

uses kantu_indicators, kantu_main;

{$R *.lfm}

{ TSimulationForm2 }

procedure TSimulationForm2.EndInSampleEditClick(Sender: TObject);
var
  date: TDateTime;
  userString: string;
begin

  DefaultFormatSettings.ShortDateFormat 	 := 'dd/mm/yyyy' ;
  DefaultFormatSettings.DateSeparator 	         := '/' ;
  DefaultFormatSettings.DecimalSeparator 	 := '.' ;

  {$IFDEF DARWIN}
  try
  UserString := InputBox('Enter date in dd/mm/yyyy format', 'Type date', DateTimeToStr(SimulationForm2.EndInSampleCalendar.Date));
  date := StrToDateTime(userString)  ;
  SimulationForm.EndInSampleCalendar.Date := date;
  EndInSampleEdit.Text := DateTimeToStr(date);
  SimulationForm2.EndInSampleCalendar.Date := SimulationForm.EndInSampleCalendar.Date;
  Except on Exception do
  ShowMessage('Invalid Date format, please enter a valid date.');
  end;
  {$ENDIF}


 {$IFNDEF DARWIN}
 if EndInSampleCalendar.Execute then  begin
    EndInSampleEdit.Text := DateTimeToStr(EndInSampleCalendar.Date);
    SimulationForm.EndInSampleCalendar.Date := SimulationForm2.EndInSampleCalendar.Date;
 end;
 {$ENDIF}


end;

procedure TSimulationForm2.EndOutOfSampleEditClick(Sender: TObject);
var
  date: TDateTime;
  userString: string;
begin

  DefaultFormatSettings.ShortDateFormat 	 := 'dd/mm/yyyy' ;
  DefaultFormatSettings.DateSeparator 	         := '/' ;
  DefaultFormatSettings.DecimalSeparator 	 := '.' ;

  {$IFDEF DARWIN}
  try
  UserString := InputBox('Enter date in dd/mm/yyyy format', 'Type date', DateTimeToStr(SimulationForm2.EndOutOfSampleCalendar.Date));
  date := StrToDateTime(userString)  ;
  SimulationForm.EndOutOfSampleCalendar.Date := date;
  EndOutOfSampleEdit.Text := DateTimeToStr(date);
  SimulationForm2.EndOutOfSampleCalendar.Date := SimulationForm.EndOutOfSampleCalendar.Date;
  Except on Exception do
  ShowMessage('Invalid Date format, please enter a valid date.');
  end;
  {$ENDIF}


 {$IFNDEF DARWIN}
 if EndOutOfSampleCalendar.Execute then  begin
    EndOutOfSampleEdit.Text := DateTimeToStr(EndOutOfSampleCalendar.Date);
    SimulationForm.EndOutOfSampleCalendar.Date := SimulationForm2.EndOutOfSampleCalendar.Date;
 end;
 {$ENDIF}

  if (EndOutOfSampleCalendar.Date < EndInSampleCalendar.Date) then
  begin
  EndOutOfSampleCalendar.Date := Now;
  SimulationForm.EndOutOfSampleCalendar.Date := SimulationForm2.EndOutOfSampleCalendar.Date;
  end;

end;

procedure TSimulationForm2.OptionsGridPrepareCanvas(sender: TObject; aCol,
  aRow: Integer; aState: TGridDrawState);
begin
end;


procedure TSimulationForm2.BeginInSampleEditClick(Sender: TObject);
var
  date: TDateTime;
  userString: string;
begin

  DefaultFormatSettings.ShortDateFormat 	 := 'dd/mm/yyyy' ;
  DefaultFormatSettings.DateSeparator 	         := '/' ;
  DefaultFormatSettings.DecimalSeparator 	 := '.' ;


  {$IFDEF DARWIN}
  try

  UserString := InputBox('Enter date in dd/mm/yyyy format', 'Type date', DateTimeToStr(SimulationForm2.BeginInSampleCalendar.Date)  )  ;


  date := StrToDateTime(userString)  ;
  SimulationForm.BeginInSampleCalendar.Date := date;
  BeginInSampleEdit.Text := DateTimeToStr(date);
  SimulationForm2.BeginInSampleCalendar.Date := SimulationForm.BeginInSampleCalendar.Date;
  Except on Exception do
  ShowMessage('Invalid Date format, please enter a valid date.');
  end;
  {$ENDIF}


 {$IFNDEF DARWIN}
 if BeginInSampleCalendar.Execute then  begin
    BeginInSampleEdit.Text := DateTimeToStr(BeginInSampleCalendar.Date);
    SimulationForm.BeginInSampleCalendar.Date := SimulationForm2.BeginInSampleCalendar.Date;
 end;
 {$ENDIF}

end;

procedure TSimulationForm2.OptionsGridEditingDone(Sender: TObject);
var
  i:integer;
begin

  for i := 1 to SimulationForm2.OptionsGrid.RowCount-1 do
   begin
   SimulationForm.OptionsGrid.Cells[1,i] := SimulationForm2.OptionsGrid.Cells[1,i];
   end;

end;

procedure TSimulationForm2.OptTargetComboBoxChange(Sender: TObject);
begin
     SimulationForm.OptTargetComboBox.ItemIndex := SimulationForm2.OptTargetComboBox.ItemIndex;
end;

procedure TSimulationForm2.FixComplexityCheckChange(Sender: TObject);
begin
    SimulationForm.FixComplexityCheck.Checked := SimulationForm2.FixComplexityCheck.Checked;
end;

procedure TSimulationForm2.EndOutOfSampleCalendarDayChanged(Sender: TObject);
begin
    SimulationForm.EndOutOfSampleCalendar.Date := SimulationForm2.EndOutOfSampleCalendar.Date;
end;

procedure TSimulationForm2.EndInSampleCalendarDayChanged(Sender: TObject);
begin
  SimulationForm.EndInSampleCalendar.Date := SimulationForm2.EndInSampleCalendar.Date;
end;

procedure TSimulationForm2.BeginInSampleCalendarDayChanged(Sender: TObject);
begin
  SimulationForm.BeginInSampleCalendar.Date := SimulationForm2.BeginInSampleCalendar.Date;
  BeginInSampleEdit.Text := DateTimeToStr(BeginInSampleCalendar.Date);
end;

procedure TSimulationForm2.BeginInSampleEditChange(Sender: TObject);
begin

end;

procedure TSimulationForm2.Button1Click(Sender: TObject);
begin
     if OptionsPanel.Visible = false then
        begin
            OptionsPanel.Visible := true  ;
            Button1.Caption := 'Hide Options' ;
        end else begin
            OptionsPanel.Visible := false;
            Button1.Caption := 'Show Options' ;
        end;
end;


procedure TSimulationForm2.EndOutOfSampleEditChange(Sender: TObject);
begin

end;

procedure TSimulationForm2.UseAlwaysUpTLCheckChange(Sender: TObject);
begin
      SimulationForm.UseAlwaysUpTLCheck.Checked := SimulationForm2.UseAlwaysUpTLCheck.Checked   ;

end;

procedure TSimulationForm2.UsedInputsListClickCheck(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to SimulationForm.UsedInputsList.Count-1 do
   SimulationForm.UsedInputsList.Checked[i] := SimulationForm2.UsedInputsList.Checked[i];
end;

procedure TSimulationForm2.UseFixedHourChange(Sender: TObject);
begin
     SimulationForm.UseFixedHour.Checked := SimulationForm2.UseFixedHour.Checked
end;

procedure TSimulationForm2.UseFixedSLTPChange(Sender: TObject);
begin
    SimulationForm.UseFixedSLTP.Checked := SimulationForm2.UseFixedSLTP.Checked
end;

procedure TSimulationForm2.AsymmetryCheckChange(Sender: TObject);
var
asymmetryString: string;
begin
  SimulationForm.AsymmetryCheck.Checked := SimulationForm2.AsymmetryCheck.Checked;

  asymmetryString := '';

  if SimulationForm.AsymmetryCheck.Checked then
  begin
       while (asymmetryString <> 'long') and (asymmetryString <> 'short') do
       asymmetryString :=  InputBox('Asymmetry definition', 'Which type of positions do you want? (long = only longs or short = only shorts)', '');
  end;

  if asymmetryString = 'long' then
  begin
       globalAllowLongSignals := true ;
       globalAllowShortSignals := false ;
  end;

  if asymmetryString = 'short' then
  begin
       globalAllowLongSignals := false ;
       globalAllowShortSignals := true ;
  end;

end;

procedure TSimulationForm2.LROriginCheckChange(Sender: TObject);
begin
    SimulationForm.LROriginCheck.Checked := SimulationForm2.LROriginCheck.Checked;
end;

procedure TSimulationForm2.UseDayFilterChange(Sender: TObject);
begin
    SimulationForm.UseDayFilter.Checked := SimulationForm2.UseDayFilter.Checked;
end;

procedure TSimulationForm2.UseHourFilterChange(Sender: TObject);
begin
   SimulationForm.UseHourFilter.Checked := SimulationForm2.UseHourFilter.Checked;
end;

procedure TSimulationForm2.UseSLCheckChange(Sender: TObject);
begin
    SimulationForm.UseSLCheck.Checked := SimulationForm2.UseSLCheck.Checked;
end;

procedure TSimulationForm2.UseTimeExitChange(Sender: TObject);
begin
     SimulationForm.UseTimeExit.Checked := SimulationForm2.UseTimeExit.Checked;
end;

procedure TSimulationForm2.UseTPCheckChange(Sender: TObject);
begin

  SimulationForm.UseTPCheck.Checked := SimulationForm2.UseTPCheck.Checked;
end;

end.

