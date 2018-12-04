program delphi_arduino_multisensor;
{Copyright © 2007, Gary Darby,  www.DelphiForFun.org
 This program may be used or modified for any non-commercial purpose
 so long as this original notice remains in place.
 All other rights are reserved
 }

uses
  Forms,
  UnitSetting in 'UnitSetting.pas' {FormSetting};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormSetting, FormSetting);
  Application.Run;
end.
