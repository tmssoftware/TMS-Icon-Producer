unit USettings;

interface
type
  TSettings = record
  public
    Persist: boolean;
    MasterFolder: string;
    GeneratedFolder: string;
    GenerateIPhone: boolean;
    GenerateIPad: boolean;
    GenerateAndroid: boolean;
    OnlyGenerateRequired: boolean;
    CreateNewFiles: boolean;
    OptimizePng: boolean;
    OutputPattern: string;
    OutputPatternOnDisk: string;
    ImgBackColor: integer;

    CmdOptimizer: string;
    CmdResizer: string;

    constructor Create(const initialize: boolean);
    procedure SaveToDisk(const Filename: string; const forced: boolean);
    procedure LoadFromDisk(const Filename: string; const DefaultSettings: TSettings);

  end;

implementation
uses System.IniFiles, IOUtils, SysUtils;

const
  StrFolders = 'Folders';
  StrMasterFolder = 'MasterFolder';
  StrGeneratedFolder = 'GeneratedFolder';
  StrGenerate = 'Generate';
  StrIPhone = 'iPhone';
  StrIPad = 'iPad';
  StrAndroid = 'Android';
  StrOnlyRequired = 'OnlyRequired';
  StrCreateNewFiles = 'CreateNewFiles';
  StrOptions = 'Options';
  StrOptimizePng = 'OptimizePng';
  StrPattern = 'Pattern';
  StrOutputPattern = 'OutputPattern';
  StrOutputPatternOnDisk = 'OutputPatternOnDisk';
  StrImgBackColor = 'ImageBackColor';

{ TSettings }

procedure TSettings.SaveToDisk(const Filename: string; const forced: boolean);
var
  s: TIniFile;
begin
  if not Persist then exit;
  if (not forced) and (not TFile.Exists(Filename)) then exit;

  s := TIniFile.Create(Filename);
  try
    s.WriteString(StrFolders, StrMasterFolder, MasterFolder);
    s.WriteString(StrFolders, StrGeneratedFolder, GeneratedFolder);
    s.WriteBool(StrGenerate, StrIPhone, GenerateIPhone);
    s.WriteBool(StrGenerate, StrIPad, GenerateIPad);
    s.WriteBool(StrGenerate, StrAndroid, GenerateAndroid);
    s.WriteBool(StrGenerate, StrOnlyRequired, OnlyGenerateRequired);
    s.WriteBool(StrGenerate, StrCreateNewFiles, CreateNewFiles);
    s.WriteBool(StrOptions, StrOptimizePng, OptimizePng);
    s.WriteString(StrPattern, StrOutputPattern, OutputPattern);
    s.WriteString(StrPattern, StrOutputPatternOnDisk, OutputPatternOnDisk);
    s.WriteInteger(StrOptions, StrImgBackColor, ImgBackColor);
  finally
    s.Free;
  end;
end;

constructor TSettings.Create(const initialize: boolean);
begin
  Persist := true;
  MasterFolder := 'master_icons';
  GeneratedFolder := 'icons';
  GenerateIPhone :=  true;
  GenerateIPad :=  true;
  GenerateAndroid :=  true;
  OnlyGenerateRequired :=  false;
  CreateNewFiles := true;
  OptimizePng :=  true;
  OutputPattern := '%4:s_%0:dx%1:d.png';
  OutputPatternOnDisk := '%4:s_%5:s.png';
  ImgBackColor := 0;

  CmdOptimizer := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'lib/truepng.exe');
  CmdResizer := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'lib/convert.exe');
end;

procedure TSettings.LoadFromDisk(const Filename: string; const DefaultSettings: TSettings);
var
  s: TIniFile;
begin
  s := TIniFile.Create(Filename);
  try
    MasterFolder := s.ReadString(StrFolders, StrMasterFolder, DefaultSettings.MasterFolder);
    GeneratedFolder := s.ReadString(StrFolders, StrGeneratedFolder, DefaultSettings.GeneratedFolder);
    GenerateIPhone := s.ReadBool(StrGenerate, StrIPhone, DefaultSettings.GenerateIPhone);
    GenerateIPad := s.ReadBool(StrGenerate, StrIPad, DefaultSettings.GenerateIPad);
    GenerateAndroid := s.ReadBool(StrGenerate, StrAndroid, DefaultSettings.GenerateAndroid);
    OnlyGenerateRequired := s.ReadBool(StrGenerate, StrOnlyRequired, DefaultSettings.OnlyGenerateRequired);
    CreateNewFiles := s.ReadBool(StrGenerate, StrCreateNewFiles, DefaultSettings.CreateNewFiles);
    OptimizePng := s.ReadBool(StrOptions, StrOptimizePng, DefaultSettings.OptimizePng);
    OutputPattern := s.ReadString(StroutputPattern, StrOutputPattern, DefaultSettings.OutputPattern);
    OutputPatternOnDisk := s.ReadString(StroutputPattern, StrOutputPatternOnDisk, DefaultSettings.OutputPatternOnDisk);
    ImgBackColor := s.ReadInteger(StrOptions, StrImgBackColor, DefaultSettings.ImgBackColor);

  finally
    s.Free;
  end;
end;

end.
