unit UnitSetting;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, CPort, Vcl.ExtCtrls,
  Vcl.ComCtrls, Math, CPortCtl, IniFiles;

type
  TStringArray = array of string;
  TFormSetting = class(TForm)
    ComPortSetting: TComPort;
    PanelSetting: TPanel;
    EditRH: TEdit;
    RHLabel: TLabel;
    TTLabel: TLabel;
    TDLabel: TLabel;
    EditTD: TEdit;
    EditTT: TEdit;
    SDMemo: TMemo;
    OpenCLose_Bt: TButton;
    SDLabel: TLabel;
    DDLabel: TLabel;
    EditDD: TEdit;
    FFLabel: TLabel;
    EditFF: TEdit;
    PPLabel: TLabel;
    EditPP: TEdit;
    P0Label: TLabel;
    EditP0: TEdit;
    RRLabel: TLabel;
    EditRR: TEdit;
    IDLabel: TLabel;
    THNEdit: TEdit;
    THNLabel: TLabel;
    EditID: TEdit;
    BLNLabel: TLabel;
    BLNEdit: TEdit;
    TGLLabel: TLabel;
    TGLEdit: TEdit;
    JAMLabel: TLabel;
    JAMEdit: TEdit;
    MNTLabel: TLabel;
    MNTEdit: TEdit;
    DTKLabel: TLabel;
    DTKEdit: TEdit;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    PortSetting: TComComboBox;
    PortBaud: TComComboBox;
    Label1: TLabel;
    BaudLabel: TLabel;
    Exit_Bt: TButton;
    HILabel: TLabel;
    EditHI: TEdit;
    Label3: TLabel;
    ListBoxParse: TListBox;
    Timer2: TTimer;
    ALTLabel: TLabel;
    EditALT: TEdit;
    Label4: TLabel;



    procedure Setting_BTClick(Sender: TObject);
    procedure OpenCLose_BtClick(Sender: TObject);
    procedure ComPortSettingAfterClose(Sender: TObject);
    procedure ComPortSettingAfterOpen(Sender: TObject);
    procedure ComPortSettingRxChar(Sender: TObject; Count: Integer);
    procedure Exit_BtClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    GStr : string;
  end;

var
  FormSetting: TFormSetting;

implementation


{$R *.dfm}

function Split(const Text, Delimiter: string): TStringArray;
var
  i: integer;
  Len: integer;
  PosStart: integer;
  PosDel: integer;
  TempText:string;
begin
  i := 0;
  SetLength(Result, 1);
  Len := Length(Delimiter);
  PosStart := 1;
  PosDel := Pos(Delimiter, Text);
  TempText:=  Text;
  while PosDel > 0 do
    begin
      Result[i] := Copy(TempText, PosStart, PosDel - PosStart);
      PosStart := PosDel + Len;
      TempText:=Copy(TempText, PosStart, Length(TempText));
      PosDel := Pos(Delimiter, TempText);
      PosStart := 1;
      inc(i);
      SetLength(Result, i + 1);
    end;
  Result[i] := Copy(TempText, PosStart, Length(TempText));
end;



procedure TFormSetting.OpenCLose_BtClick(Sender: TObject);
begin
ComPortSetting.Port := PortSetting.Text;
ComPortSetting.BaudRate := StrToBaudRate(PortBaud.Text);
  if ComPortSetting.Connected then
    begin
    ComPortSetting.Close;
    Timer2.Enabled := False;
    end
  else
    begin
    ComPortSetting.Open;
    Timer2.Enabled := True;
    end;

end;

procedure TFormSetting.Setting_BTClick(Sender: TObject);
begin
ComPortSetting.ShowSetupDialog;
end;

procedure TFormSetting.Timer2Timer(Sender: TObject);
var
linecount : Integer;
Tampung : TStringArray;

begin
  linecount := SDMemo.Lines.Count - 1;
  Tampung := Split(SDMemo.Lines[linecount],';');
  EditID.Text := Tampung[0];//id sta
  EditRH.Text := Tampung[1];//humidityString
  EditTT.Text := Tampung[2];//temperatureCString
  EditTD.Text := Tampung[3];//dpString
  EditHI.Text := Tampung[4];//heatindexString
  EditPP.Text := Tampung[5];//pressureStringQNH
  EditP0.Text := Tampung[6];//pressureStringQFE
  EditALT.Text := Tampung[7];//pressureALT
end;

procedure TFormSetting.Exit_BtClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFormSetting.ComPortSettingAfterClose(Sender: TObject);
begin
OpenCLose_Bt.Caption := 'Open';
end;

procedure TFormSetting.ComPortSettingAfterOpen(Sender: TObject);
begin
OpenCLose_Bt.Caption := 'Close';
end;

procedure TFormSetting.ComPortSettingRxChar(Sender: TObject; Count: Integer);
var
rStr : string;
begin
  ComPortSetting.ReadStr( rStr, Count );
  if rStr = 'Failed to read from DHT sensor!' then
  begin
    OpenCLose_Bt.Click;
    Sleep(1000);
    OpenCLose_Bt.Click;
  end;

  SDMemo.Text:=SDMemo.Text + rStr;


end;

end.
