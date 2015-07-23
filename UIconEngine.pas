unit UIconEngine;

interface
uses USettings, Generics.Collections, XmlDoc,
     Xml.XMLIntf, UPredefinedSizes, ULogger,
     Graphics, SysUtils, System.Types;

type
  TIconEngine = class
  private
    BaseFileName: string;
    ImageList: TDictionary<string, string>;
    PredefinedSizes: TPredefinedSizes;
    FLog: TLogger;
    DefaultSettings: TSettings;

    procedure LoadSettings;
    procedure LoadImages(const folder: string);
    function GetImageId(const w, h: integer): string;
    procedure SaveImages(const folder: string);
    procedure ProcessPropGroup(const AlreadyProcessed: TDictionary<string, boolean>; Proj: IXmlDocument; PropGroup: IXmlNode; var ProcessedCount: integer);
    procedure ProcessProject(Proj: IXmlDocument; ProjNode: IXmlNode);
    function ProcessIcon(const AlreadyProcessed: TDictionary<string, boolean>; Icon: IXmlNode; const prefix: string; var ProcessedCount: integer): boolean;
    function GetPlat(const s: string): string;
    function GetTarget(const s: string): string;
    function IsNumberOrX(const c: char): boolean;
    procedure ClearDestFolder;
    function TryToGenerate(const sz: TSize; const NodeName: string; out SourceFileName: string): boolean;
    function GetDestFileName(const Pattern: string; sz: TSize; NodeName, SourceFileName: string): string;
    procedure CopyIcon(const NodeName: string; var GeneratedInPlace: boolean; var Skip: Boolean; sz: TSize; var SourceFileName: string; var DestFileName: string);
    function SkipIcon(const sz: TSize): boolean;
    function SkipLaunch(const sz: TSize): boolean;
    function TryToGenerateRect(const sz: TSize; const SourceFileName: string): boolean;
    function TryToGenerateSquare(const sz: TSize; const SourceFileName: string): boolean;
    function FindRectImg(const sz: TSize; out FileName: string; out OrigSz: TSize): boolean;
    function FindSquareImg(const sz: TSize; out FileName: string): boolean;
    function GetColorHex(cl: TColor): string;
    function GetSizeFromId(const s: string): TSize;
    function CalcRatio(const sz: TSize): double;
    function NearestRatio(const DesiredRatio: double; const sz1,
      sz2: TSize): boolean;
  public
    Settings: TSettings;

    constructor Create(const aBaseFileName: string; const aDefaultSettings: TSettings; const aLogger: TLogger);
    destructor Destroy; override;

    procedure SaveSettings(const forced: boolean);

    function FullMasterFolder: string;
    function FullGeneratedFolder: string;

    procedure GenerateFiles;

    property Log: TLogger read FLog write FLog;
  end;


implementation
uses IOUtils, PngImage, URunner, Windows;

const
  IconSpreadFileName = '.IconSpread';

{ TIconEngine }

constructor TIconEngine.Create(const aBaseFileName: string; const aDefaultSettings: TSettings; const aLogger: TLogger);
begin
  BaseFileName := aBaseFileName;
  ImageList := TDictionary<string, string>.Create;
  DefaultSettings := aDefaultSettings;
  Settings := DefaultSettings;
  LoadSettings;
  PredefinedSizes := TPredefinedSizes.Create;
  Log := aLogger;
end;

destructor TIconEngine.Destroy;
begin
  PredefinedSizes.Free;
  ImageList.Free;
  inherited;
end;

procedure TIconEngine.GenerateFiles;
begin
  LoadImages(FullMasterFolder);
  SaveImages(FullGeneratedFolder);
end;

//see https://developer.apple.com/library/ios/qa/qa1686/_index.html
//see https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/IconMatrix.html#//apple_ref/doc/uid/TP40006556-CH27-SW2
function TIconEngine.SkipIcon(const sz: TSize): boolean;
begin
  if sz.cx <> sz.cy then exit(SkipLaunch(sz));

  if Settings.GenerateIPhone then
  begin
    case sz.cx of
       57,
       120,
       180: exit(false);
    end;
  end;

  if Settings.GenerateIPad then
  begin
    case sz.cx of
       72,
       76,
       152: exit(false);
    end;
  end;

  if Settings.GenerateAndroid then
  begin
    case sz.cx of
       48,
       72,
       96,
       144,
       192: exit(false);
    end;
  end;

  Result := true;
end;

function TIconEngine.SkipLaunch(const sz: TSize): boolean;
begin
  if Settings.GenerateIPhone then
  begin
    case sz.cx of
      750: if sz.cy = 1334 then exit(false); //6
      1334: if sz.cy = 750 then exit(false); //6
      1242:  if sz.cy = 2208 then exit(false); //6+
      2208:  if sz.cy = 1242 then exit(false); //6+
      640:
      begin
        if sz.cy = 960 then exit(false);  //4
        if sz.cy = 1136 then exit(false); //5
      end;

    end;
  end;

  if Settings.GenerateIPad then
  begin
    case sz.cx of
      1536: if sz.cy = 2048 then exit(false); //2x
      2048: if sz.cy = 1536 then exit(false); //2x
      768:  if sz.cy = 1024 then exit(false); //1x
      1024:  if sz.cy = 768 then exit(false); //1x
    end;
  end;

  //http://stackoverflow.com/questions/13487124/android-splash-screen-sizes-for-ldpi-mdpi-hdpi-xhdpi-displays-eg-1024x76
  if Settings.GenerateAndroid then
  begin
    case sz.cx of
       960: if sz.cy = 720 then exit(false);
       640: if sz.cy = 480 then exit(false);
       470: if sz.cy = 320 then exit(false);
       426: if sz.cy = 320 then exit(false);
    end;
  end;

  Result := true;
end;

procedure TIconEngine.CopyIcon(const NodeName: string; var GeneratedInPlace: boolean; var Skip: Boolean; sz: TSize; var SourceFileName: string; var DestFileName: string);
begin
  if not ImageList.TryGetValue(GetImageId(sz.Width, sz.Height), SourceFileName) then
  begin
    if (Settings.OnlyGenerateRequired and SkipIcon(sz)) or (not Settings.CreateNewFiles) then
    begin
      Skip := true;
      Log(TLogChannel.Main, 'Skipped: ' + IntToStr(sz.Width) + 'x' + IntToStr(sz.Height));
      exit;
    end;
    if not TryToGenerate(sz, NodeName, SourceFileName) then
      raise Exception.Create('Image with size ' + NodeName + ' doesn''t exist. Size: ' + IntToStr(sz.Width) + 'x' + IntToStr(sz.Height));
    GeneratedInPlace := true;
    Log(TLogChannel.Main, 'AutoGenerated: ' + TPath.GetFileName(SourceFileName));
  end;
  DestFileName := GetDestFileName(Settings.OutputPattern, sz, NodeName, SourceFileName);
  if not GeneratedInPlace then
    Log(TLogChannel.Main, 'Renamed: ' + TPath.GetFileName(SourceFileName) + ' -> ' + TPath.GetFileName(DestFileName));
end;

function TIconEngine.GetDestFileName(const Pattern: string; sz: TSize; NodeName, SourceFileName: string): string;
begin
  Result := Format(Pattern, [sz.Width, sz.Height, GetPlat(NodeName), GetTarget(NodeName), TPath.GetFileNameWithoutExtension(BaseFileName), TPath.GetFileNameWithoutExtension(SourceFileName)]);
end;

function TIconEngine.FullGeneratedFolder: string;
begin
  if TPath.IsRelativePath(Settings.GeneratedFolder) then exit (TPath.Combine(TPath.GetDirectoryName(BaseFileName), Settings.GeneratedFolder));
  Result := Settings.GeneratedFolder;
end;

function TIconEngine.FullMasterFolder: string;
begin
  if TPath.IsRelativePath(Settings.MasterFolder) then exit (TPath.Combine(TPath.GetDirectoryName(BaseFileName), Settings.MasterFolder));
  Result := Settings.MasterFolder;
end;

function TIconEngine.GetImageId(const w, h: integer): string;
begin
  Result := IntToStr(w) + 'x' + IntToStr(h);
end;

function TIconEngine.GetSizeFromId(const s: string): TSize;
begin
  Result.Width := StrToInt(s.Substring(0, s.IndexOf('x')));
  Result.Height := StrToInt(s.Substring(s.IndexOf('x') + 1));
end;

procedure TIconEngine.LoadImages(const folder: string);
var
  files: TStringDynArray;
  fi, fiold: string;
  id: string;
  Image: TPngImage;
begin
  ImageList.Clear;
  files := TDirectory.GetFiles(folder, '*.png', TSearchOption.soAllDirectories);
  for fi in files do
  begin
    Image := TPngImage.Create;
    try
      Image.LoadFromFile(fi);
      id := GetImageId(Image.Width, Image.Height);
      if ImageList.TryGetValue(id, fiold) then raise Exception.Create('Images "' + fiold + '" and "' + fi + '" in the master folder have the same dimensions (' + Id + '). Please delete one.');

      ImageList.AddOrSetValue(Id , fi);
    finally
      Image.Free;
    end;

  end;
end;

procedure TIconEngine.ClearDestFolder;
var
  f: TStringDynArray;
  i: Integer;
begin
  f := TDirectory.GetFiles(FullGeneratedFolder, '*.png', TSearchOption.soTopDirectoryOnly);
  for i := 0 to Length(f) - 1 do
  begin
    TFile.Delete(f[i]);
  end;
end;

procedure TIconEngine.SaveImages(const folder: string);
var
  Proj: IXMLDocument;
  PropGroups: IXmlNodeList;
  ProjNode: IXmlNode;
  i: Integer;
begin
  ClearDestFolder;
  Proj := TXMLDocument.Create(nil);
  Proj.ParseOptions := Proj.ParseOptions + [poPreserveWhiteSpace];

  Proj.LoadFromFile(BaseFileName);
  PropGroups := Proj.ChildNodes;
  for i := 0 to PropGroups.Count - 1 do
  begin
    ProjNode := PropGroups[i];
    if ProjNode.NodeName <> 'Project' then continue;

    ProcessProject(Proj, ProjNode);
  end;

  Proj.SaveToFile(BaseFileName);

end;

procedure TIconEngine.ProcessProject(Proj: IXmlDocument; ProjNode: IXmlNode);
var
  PropGroups: IXmlNodeList;
  PropGroup: IXmlNode;
  i: integer;
  ProcessedCount: integer;
  AlreadyProcessed: TDictionary<string, boolean>;
begin
  ProcessedCount := 0;
  AlreadyProcessed := TDictionary<string, boolean>.Create;
  try
    PropGroups := ProjNode.ChildNodes;
    for i := 0 to PropGroups.Count - 1 do
    begin
      PropGroup := PropGroups[i];
      if PropGroup.NodeName <> 'PropertyGroup' then continue;

      ProcessPropGroup(AlreadyProcessed, Proj, PropGroup, ProcessedCount);
    end;
  finally
    AlreadyProcessed.Free;
  end;
end;

procedure TIconEngine.ProcessPropGroup(const AlreadyProcessed: TDictionary<string, boolean>; Proj: IXmlDocument; PropGroup: IXmlNode; var ProcessedCount: integer);
var
  PropGroupItems: IXmlNodeList;
  Icon: IXmlNode;
  i: integer;
begin
  PropGroupItems := PropGroup.ChildNodes;
  for i := 0 to PropGroupItems.Count - 1 do
  begin
    Icon := PropGroupItems[i];
    if Settings.GenerateIPhone then
    begin
      if ProcessIcon(AlreadyProcessed, Icon, 'iPhone_AppIcon', ProcessedCount) then continue;
      if ProcessIcon(AlreadyProcessed, Icon, 'iPhone_Spotlight', ProcessedCount) then continue;
      if ProcessIcon(AlreadyProcessed, Icon, 'iPhone_Setting', ProcessedCount) then continue;
      if ProcessIcon(AlreadyProcessed, Icon, 'iPhone_Launch', ProcessedCount) then continue;
    end;

    if Settings.GenerateIPad then
    begin
      if ProcessIcon(AlreadyProcessed, Icon, 'iPad_AppIcon', ProcessedCount) then continue;
      if ProcessIcon(AlreadyProcessed, Icon, 'iPad_SpotLight', ProcessedCount) then continue;
      if ProcessIcon(AlreadyProcessed, Icon, 'iPad_Setting', ProcessedCount) then continue;
      if ProcessIcon(AlreadyProcessed, Icon, 'iPad_Launch', ProcessedCount) then continue;
    end;

    if (Settings.GenerateAndroid) then
    begin
      if ProcessIcon(AlreadyProcessed, Icon, 'Android_SplashImage', ProcessedCount) then continue;
      if ProcessIcon(AlreadyProcessed, Icon, 'Android_LauncherIcon', ProcessedCount) then continue;
    end;

  end;
end;

function TIconEngine.ProcessIcon(const AlreadyProcessed: TDictionary<string, boolean>; Icon: IXmlNode; const prefix: string; var ProcessedCount: integer): boolean;
var
  NameOnDisk: string;
  SourceFileName, DestFileName: string;
  sz: TSize;
  GeneratedInPlace: boolean;
  Skip: Boolean;
  FullDest: string;
begin
  Skip := false;
  if (not Icon.NodeName.StartsWith(prefix)) then exit(false);
  Inc(ProcessedCount);
  Log(TLogChannel.Count, IntToStr(ProcessedCount));
  GeneratedInPlace := false;
  sz := PredefinedSizes.GetSize(Icon.NodeName);
  NameOnDisk := TPath.Combine(FullMasterFolder, Icon.NodeName + '.png');
  if TFile.Exists(NameOnDisk) then
  begin
    SourceFileName := NameOnDisk;
    DestFileName := GetDestFileName(Settings.OutputPatternOnDisk, sz, Icon.NodeName, SourceFileName);

    Log(TLogChannel.Main, 'Direct: ' + TPath.GetFileName(SourceFileName) + ' -> ' + TPath.GetFileName(DestFileName));
  end
  else
  begin
    CopyIcon(Icon.NodeName, GeneratedInPlace, Skip, sz, SourceFileName, DestFileName);
  end;

  if not Skip then
  begin
    FullDest := TPath.Combine(FullGeneratedFolder, DestFileName);
    if not AlreadyProcessed.ContainsKey(FullDest) then
    begin
      if not GeneratedInPlace then TFile.Copy(SourceFileName, FullDest, true);
      if (Settings.OptimizePng) then Run(Log, TLogChannel.Optimize, Settings.CmdOptimizer, FullGeneratedFolder, ' "' + FullDest + '"');
      AlreadyProcessed.Add(FullDest, true);
    end;
    Icon.Text := TPath.Combine(Settings.GeneratedFolder, TPath.GetFileName(DestFileName));
  end
  else
  begin
    Icon.Text := '';
  end;


  Result := true;
end;

function TIconEngine.GetColorHex(cl: TColor): string;
var
  c: integer;
begin
  c := ColorToRGB(cl);
  Result :=
     '"#' +
     IntToHex(GetRValue(c), 2) +
     IntToHex(GetGValue(c), 2) +
     IntToHex(GetBValue(c), 2) +
     '"';
end;

function TIconEngine.FindSquareImg(const sz: TSize; out FileName: string): boolean;
var
  key: string;
  ksz, rsz: TSize;
  FoundBigger: boolean;
begin
  FileName := '';
  Result := false;
  FoundBigger := false;
  rsz := TSize.Create(0, 0);
  for key in ImageList.Keys do
  begin
    ksz := GetSizeFromId(key);
    if (ksz.Width <> ksz.Height) then continue;

    if (ksz.Width < sz.Width) then
    begin
      if not FoundBigger and (rsz.Width < ksz.Width) then rsz := ksz;
    end else
    begin
      if (rsz.Width = 0) or (not FoundBigger) or (rsz.Width > ksz.Width) then rsz := ksz;
      FoundBigger := true;
    end;
  end;

  if rsz.Width > 0 then
  begin
    FileName := ImageList[GetImageId(rsz.Width, rsz.Height)];
    exit(true);
  end;
end;

function TIconEngine.CalcRatio(const sz: TSize): double;
begin
  Result := sz.Width / sz.Height;
end;

function TIconEngine.NearestRatio(const DesiredRatio: double; const sz1, sz2: TSize): boolean;
begin
  Result := Abs(DesiredRatio - CalcRatio(sz1)) < Abs(DesiredRatio - CalcRatio(sz2));
end;

function TIconEngine.FindRectImg(const sz: TSize; out FileName: string; out OrigSz: TSize): boolean;
var
  key: string;
  ksz, rsz: TSize;
  Ratio: double;
  FoundBigger: boolean;
begin
  FileName := '';
  Result := false;
  FoundBigger := false;
  Ratio := CalcRatio(sz);
  rsz := TSize.Create(0, 0);
  for key in ImageList.Keys do
  begin
    ksz := GetSizeFromId(key);
    if (ksz.Width = ksz.Height) then continue;

    if (ksz.Width < sz.Width) and (ksz.Height < ksz.Height) then
    begin
      if (not FoundBigger) and NearestRatio(Ratio, ksz, rsz) then rsz := ksz;
    end else
    begin
      if (rsz.Width = 0) or (not FoundBigger) or NearestRatio(Ratio, ksz, rsz) then rsz := ksz;
      FoundBigger := true;
    end;
  end;

  if rsz.Width > 0 then
  begin
    FileName := ImageList[GetImageId(rsz.Width, rsz.Height)];
    exit(true);
  end;
end;

function TIconEngine.TryToGenerate(const sz: TSize; const NodeName: string; out SourceFileName: string): boolean;
begin
  SourceFileName := TPath.Combine(FullGeneratedFolder, GetDestFileName(Settings.OutputPattern, sz, NodeName, SourceFileName));

  if sz.Height <> sz.Width then exit(TryToGenerateRect(sz, SourceFileName));
  Result := TryToGenerateSquare(sz, SourceFileName);
end;

function TIconEngine.TryToGenerateSquare(const sz: TSize; const SourceFileName: string): boolean;
var
  OrigFileName: string;
begin
  if not FindSquareImg(sz, OrigFileName) then exit(false);

  Run(Log, TLogChannel.Resize, Settings.CmdResizer, TPath.GetDirectoryName(SourceFileName),
  '"' + OrigFileName + '" -resize ' + IntToStr(sz.Width) + ' -verbose "' + SourceFileName + '"' );
  Result := true;
end;

function TIconEngine.TryToGenerateRect(const sz: TSize; const SourceFileName: string): boolean;
var
  OrigFileName: string;
  OrigSz: TSize;
  NewSize: string;
begin
  if not FindRectImg(sz, OrigFileName, OrigSz) then exit(false);

  NewSize := IntToStr(sz.Width) + 'x' + IntToStr(sz.Height);
  Run(Log, TLogChannel.Resize, Settings.CmdResizer, TPath.GetDirectoryName(SourceFileName),
  '"' + OrigFileName + '" -resize ' + NewSize
  + ' -gravity center -background '
  + GetColorHex(TColor(Settings.ImgBackColor))
  + ' -extent ' + NewSize
  + ' -verbose "' + SourceFileName + '"' );
  Result := true;
end;

procedure TIconEngine.LoadSettings;
begin
  Settings.LoadFromDisk(BaseFileName + IconSpreadFileName, DefaultSettings);
end;

procedure TIconEngine.SaveSettings(const forced: boolean);
begin
  Settings.SaveToDisk(BaseFileName + IconSpreadFileName, forced);
end;

function TIconEngine.GetPlat(const s: string): string;
begin
  Result := s.Substring(0, s.IndexOf('_'));
end;

function TIconEngine.GetTarget(const s: string): string;
begin
  Result := s.Substring(s.IndexOf('_') + 1);
  while (Result.Length > 0) and IsNumberOrX(Result[Result.Length - 1]) do Result := Result.Remove(Result.Length - 1);

end;

function TIconEngine.IsNumberOrX(const c: char): boolean;
begin
  if c = 'x' then exit(true);
  if (c >= '0') and (c <= '9') then exit(true);
  Result := false;
end;

end.
