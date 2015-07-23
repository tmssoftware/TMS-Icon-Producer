program IconSpread;

uses
  Vcl.Forms,
  UIconData in 'UIconData.pas',
  UCaptionFrame in 'UCaptionFrame.pas' {CaptionFrame: TFrame},
  UIconEngine in 'UIconEngine.pas',
  USettings in 'USettings.pas',
  UExportImagesForm in 'UExportImagesForm.pas' {ExportImagesForm},
  UPredefinedSizes in 'UPredefinedSizes.pas',
  ULogger in 'ULogger.pas',
  URunner in 'URunner.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TExportImagesForm, ExportImagesForm);
  Application.Run;
end.
