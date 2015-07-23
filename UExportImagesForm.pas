unit UExportImagesForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UIconEngine, USettings, Vcl.StdCtrls, Vcl.ExtCtrls,
  UCaptionFrame, System.Actions, Vcl.ActnList;

type
  TExportImagesForm = class(TForm)
    edOptimizePng: TCheckBox;
    OptionsPanel: TPanel;
    LogFrame: TPanel;
    LogCaption: TCaptionFrame;
    LogMemoMain: TMemo;
    CommandsPanel: TPanel;
    GoButton: TButton;
    Actions: TActionList;
    ActionGo: TAction;
    ActionExit: TAction;
    CancelButton: TButton;
    ConfigurationCaption: TCaptionFrame;
    ConfigurationPanel: TPanel;
    edMasterIconFolder: TLabeledEdit;
    btnOpenMasterInExplorer: TButton;
    btnOpenGeneratedInExplorer: TButton;
    edGeneratedIconFolder: TLabeledEdit;
    ActionsConfig: TActionList;
    ActionOpenMasterInExplorer: TAction;
    ActionOpenGeneratedInExplorer: TAction;
    LogMemoOptimize: TMemo;
    LogMemoResize: TMemo;
    Log2Panel: TPanel;
    SplitterLogs1: TSplitter;
    Splitter1: TSplitter;
    cbGenerateIphone: TCheckBox;
    cbGenerateIpad: TCheckBox;
    cbGenerateAndroid: TCheckBox;
    cbOnlyRequired: TCheckBox;
    BackColorDialog: TColorDialog;
    PanelBkColor: TPanel;
    cbCreateNewFiles: TCheckBox;
    procedure ActionExitExecute(Sender: TObject);
    procedure ActionGoExecute(Sender: TObject);
    procedure edMasterIconFolderChange(Sender: TObject);
    procedure edGeneratedIconFolderChange(Sender: TObject);
    procedure ActionOpenMasterInExplorerExecute(Sender: TObject);
    procedure ActionOpenGeneratedInExplorerExecute(Sender: TObject);
    procedure PanelBkColorClick(Sender: TObject);
  private
    FIconEngine: TIconEngine;
    procedure OpenExplorer(const dir: string);
    procedure UpdateSettings;
    procedure LoadSettings;
    procedure EnableScreen(const enable: boolean);
    function TotalCount: integer;
    function CommandLineSettings: TSettings;
    function GetString(const p, cmd: string; out s: string): boolean;
    procedure SetPanelBackColor(const colr: TColor);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property IconEngine: TIconEngine read FIconEngine write FIconEngine;
  end;

var
  ExportImagesForm: TExportImagesForm;

implementation
uses IOUtils, ShellAPI, ULogger, Threading, ActiveX, UPredefinedSizes, StrUtils;
{$R *.dfm}

function TExportImagesForm.CommandLineSettings: TSettings;
var
  i: Integer;
  r: Boolean;
  p, d: string;
begin
    Result := TSettings.Create(true);
    for i := 1 to ParamCount - 1 do
    begin
      p := Trim(ParamStr(i));
      if (p.Length = 0) then continue;
      if p.Chars[0] = '+' then r := true
      else if p.Chars[0] = '-' then r := false
      else raise Exception.Create('Parameters must start with + or -');

      p := p.Substring(1);

      if SameText(p, 'SAVESETTINGS') then begin; Result.Persist := r; continue; end;
      if SameText(p, 'IPHONE') then begin; Result.GenerateIPhone := r; continue; end;
      if SameText(p, 'IPAD') then begin; Result.GenerateIPad := r; continue; end;
      if SameText(p, 'ANDROID') then begin; Result.GenerateAndroid := r; continue; end;
      if SameText(p, 'REQUIRED') then begin; Result.OnlyGenerateRequired := r; continue; end;
      if SameText(p, 'OPTIMIZE') then begin; Result.OptimizePng := r; continue; end;
      if SameText(p, 'NEWFILES') then begin; Result.CreateNewFiles := r; continue; end;
      if GetString(p, 'MASTERFOLDER', d) then begin; Result.MasterFolder := d; continue; end;
      if GetString(p, 'GENERATEDFOLDER', d) then begin; Result.GeneratedFolder := d; continue; end;
      if GetString(p, 'OUTPUTFPATTERN', d) then begin; Result.OutputPattern := d; continue; end;
      if GetString(p, 'OUTPUTFPATTERNONDISK', d) then begin; Result.OutputPatternOnDisk := d; continue; end;
      if GetString(p, 'BACKCOLOR', d) then begin; Result.ImgBackColor := StrToInt(d); continue; end;
      if GetString(p, 'OPTIMIZER', d) then begin; Result.CmdOptimizer := d; continue; end;
      if GetString(p, 'RESIZER', d) then begin; Result.CmdResizer := d; continue; end;


      raise Exception.Create('Invalid parameter: ' + ParamStr(i));
    end;

end;

function TExportImagesForm.GetString(const p: string; const cmd: string; out s: string): boolean;
var
  k: string;
begin
  s := '';
  if not p.StartsWith(cmd) then exit(false);
  if p.Length <= cmd.Length then exit(false);
  k := p.Substring(cmd.Length).Trim;
  if (k.Length < 2) then exit(false);
  if k.Chars[0] <> '=' then exit(false);
  s := k.Substring(1).Trim;
  Result := true;
end;

constructor TExportImagesForm.Create(AOwner: TComponent);
var
  DProj: string;
begin
  inherited;
  if ParamCount < 1 then
  begin
    ShowMessage('No Project specified. Configure Tools in Rad Studio and pass $Project as parameter');
    Application.Terminate;
    exit;
  end;

  DProj := ParamStr(ParamCount);
  Caption := 'Icon Spread: ' + TPath.GetFileName(DProj);
  IconEngine := TIconEngine.Create(DProj, CommandLineSettings,
       procedure(Channel: TLogChannel; s: string)
       begin
         case Channel of
           TLogChannel.Main: TThread.Queue(nil, procedure begin LogMemoMain.Lines.Add(s); end);
           TLogChannel.Resize: TThread.Queue(nil, procedure begin LogMemoResize.Lines.Add(s); end);
           TLogChannel.Optimize: TThread.Queue(nil, procedure begin LogMemoOptimize.Lines.Add(s); end);
           TLogChannel.Count: TThread.Queue(nil, procedure begin LogCaption.Caption.Caption := 'Log:  Processed ' + s + ' images from ' + IntToStr(TotalCount); end);
         end;

       end);
  LoadSettings;
end;

destructor TExportImagesForm.Destroy;
begin
  if (IconEngine <> nil) then IconEngine.SaveSettings(false);

  IconEngine.Free;
  inherited;
end;

procedure TExportImagesForm.SetPanelBackColor(const colr: TColor);
var
  cl: Integer;
begin
  PanelBkColor.Color := colr;
  cl := ColorToRGB(colr);
  if GetRValue(cl) + GetGValue(cl) + GetBValue(cl) < 127 * 3 then
    PanelBkColor.Font.Color := clWhite
  else
    PanelBkColor.Font.Color := clBlack;
end;

procedure TExportImagesForm.edGeneratedIconFolderChange(Sender: TObject);
begin
  IconEngine.Settings.GeneratedFolder := edGeneratedIconFolder.Text;
  if TDirectory.Exists(IconEngine.FullGeneratedFolder) then edGeneratedIconFolder.Font.Color := clBlack else edGeneratedIconFolder.Font.Color := clRed;
end;

procedure TExportImagesForm.edMasterIconFolderChange(Sender: TObject);
begin
  IconEngine.Settings.MasterFolder := edMasterIconFolder.Text;
  if TDirectory.Exists(IconEngine.FullMasterFolder) then edMasterIconFolder.Font.Color := clBlack else edMasterIconFolder.Font.Color := clRed;
end;

procedure TExportImagesForm.ActionExitExecute(Sender: TObject);
begin
 Close;
end;

procedure TExportImagesForm.ActionGoExecute(Sender: TObject);
begin
  UpdateSettings;
  IconEngine.SaveSettings(true);  //only create the ini if the user tried to run the app. We don't want to pollute the disk with ini files.
  LogMemoMain.Lines.Clear;
  LogMemoOptimize.Lines.Clear;
  LogMemoResize.Lines.Clear;
  EnableScreen(false);
  TTask.Run(
    procedure
    var
      Ok: boolean;
    begin
      Ok := true;
      CoInitialize(nil);
      try
        try
          IconEngine.GenerateFiles();
        except
          on ex: Exception do
          begin
            ShowMessage('ERROR: ' + ex.Message);
            Ok := false;
          end;
        end;
      finally
        CoUninitialize;
      end;
      TThread.Queue(nil,
      procedure
      begin
        if (Ok) then ShowMessage('Done!');
        EnableScreen(True);
      end)
  end);
end;

procedure TExportImagesForm.EnableScreen(const enable: boolean);
begin
 ActionExit.Enabled := enable;
 ActionGo.Enabled := enable;
 edMasterIconFolder.Enabled := enable;
 edGeneratedIconFolder.Enabled := enable;
 OptionsPanel.Enabled := enable;
end;

procedure TExportImagesForm.LoadSettings;
begin
  edMasterIconFolder.Text := IconEngine.Settings.MasterFolder;
  edGeneratedIconFolder.Text := IconEngine.Settings.GeneratedFolder;
  edOptimizePng.Checked := IconEngine.Settings.OptimizePng;
  cbGenerateIphone.Checked := IconEngine.Settings.GenerateIPhone;
  cbGenerateIpad.Checked := IconEngine.Settings.GenerateIPad;
  cbGenerateAndroid.Checked := IconEngine.Settings.GenerateAndroid;
  cbOnlyRequired.Checked := IconEngine.Settings.OnlyGenerateRequired;
  cbCreateNewFiles.Checked := IconEngine.Settings.CreateNewFiles;
  SetPanelBackColor(TColor(IconEngine.Settings.ImgBackColor));
  BackColorDialog.Color := TColor(IconEngine.Settings.ImgBackColor);

end;

procedure TExportImagesForm.UpdateSettings;
begin
  IconEngine.Settings.MasterFolder := edMasterIconFolder.Text;
  IconEngine.Settings.GeneratedFolder := edGeneratedIconFolder.Text;
  IconEngine.Settings.OptimizePng := edOptimizePng.Checked;
  IconEngine.Settings.GenerateIPhone := cbGenerateIphone.Checked;
  IconEngine.Settings.GenerateIPad := cbGenerateIpad.Checked;
  IconEngine.Settings.GenerateAndroid := cbGenerateAndroid.Checked;
  IconEngine.Settings.OnlyGenerateRequired := cbOnlyRequired.Checked;
  IconEngine.Settings.CreateNewFiles := cbCreateNewFiles.Checked;
  IconEngine.Settings.ImgBackColor := integer(PanelBkColor.Color);

  IconEngine.SaveSettings(false);
end;


procedure TExportImagesForm.OpenExplorer(const dir: string);
begin
  if not TDirectory.Exists(dir) then
  begin
    ShowMessage('Directory doesn''t exist: ' + dir);
    exit;
  end;

  ShellExecute(Application.Handle, 'open', PWideChar(dir), '', '', SW_SHOWNORMAL);
end;

procedure TExportImagesForm.PanelBkColorClick(Sender: TObject);
begin
  BackColorDialog.Execute;
  SetPanelBackColor(BackColorDialog.Color);
  UpdateSettings;

end;

function TExportImagesForm.TotalCount: integer;
begin
  Result := 0;
  if cbGenerateAndroid.Checked then Inc(Result, AndroidImageCount);
  if cbGenerateIphone.Checked then Inc(Result, iPhoneImageCount);
  if cbGenerateIpad.Checked then Inc(Result, iPadImageCount);

end;

procedure TExportImagesForm.ActionOpenGeneratedInExplorerExecute(
  Sender: TObject);
begin
  UpdateSettings;
  OpenExplorer(IconEngine.FullGeneratedFolder);
end;

procedure TExportImagesForm.ActionOpenMasterInExplorerExecute(Sender: TObject);
begin
  UpdateSettings;
  OpenExplorer(IconEngine.FullMasterFolder);
end;

end.
