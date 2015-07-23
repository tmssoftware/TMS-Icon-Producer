unit UPredefinedSizes;

interface
uses Generics.Collections, System.Types, SysUtils;

const
  AndroidImageCount = 9;
  iPhoneImageCount = 48;
  iPadImageCount = 54;

type
  TPredefinedSizes = class
  private
    Sizes: TDictionary<String, TSize>;
    procedure Fill;
  public
    constructor Create;
    destructor Destroy; override;
    function GetSize(const tag: string): TSize;
  end;


implementation

{ TPredefinedSizes }

constructor TPredefinedSizes.Create;
begin
  Sizes := TDictionary<String, TSize>.Create;
  Fill;
end;

destructor TPredefinedSizes.Destroy;
begin
  Sizes.Free;
  inherited;
end;

procedure TPredefinedSizes.Fill;
begin
  Sizes.Add('Android_LauncherIcon36', TSize.Create(36, 36));
  Sizes.Add('Android_LauncherIcon48', TSize.Create(48, 48));
  Sizes.Add('Android_LauncherIcon72', TSize.Create(72, 72));
  Sizes.Add('Android_LauncherIcon96', TSize.Create(96, 96));
  Sizes.Add('Android_LauncherIcon144', TSize.Create(144, 144));

  Sizes.Add('Android_SplashImage426', TSize.Create(426, 320));
  Sizes.Add('Android_SplashImage470', TSize.Create(470, 320));
  Sizes.Add('Android_SplashImage640', TSize.Create(640, 480));
  Sizes.Add('Android_SplashImage960', TSize.Create(960, 720));

  Sizes.Add('iPhone_AppIcon57', TSize.Create(57, 57));
  Sizes.Add('iPhone_AppIcon60', TSize.Create(60, 60));
  Sizes.Add('iPhone_AppIcon87', TSize.Create(87, 87));
  Sizes.Add('iPhone_AppIcon114', TSize.Create(114, 114));
  Sizes.Add('iPhone_AppIcon120', TSize.Create(120, 120));
  Sizes.Add('iPhone_AppIcon180', TSize.Create(180, 180));

  Sizes.Add('iPhone_Launch320', TSize.Create(320, 480));
  Sizes.Add('iPhone_Launch640', TSize.Create(640, 960));
  Sizes.Add('iPhone_Launch640x1136', TSize.Create(640, 1136));
  Sizes.Add('iPhone_Launch750', TSize.Create(750, 1334));
  Sizes.Add('iPhone_Launch1242', TSize.Create(1242, 2208));
  Sizes.Add('iPhone_Launch2208', TSize.Create(2208, 1242));

  Sizes.Add('iPhone_Spotlight29', TSize.Create(29, 29));
  Sizes.Add('iPhone_Spotlight40', TSize.Create(40, 40));
  Sizes.Add('iPhone_Spotlight58', TSize.Create(58, 58));
  Sizes.Add('iPhone_Spotlight80', TSize.Create(80, 80));

  Sizes.Add('iPad_AppIcon72', TSize.Create(72, 72));
  Sizes.Add('iPad_AppIcon76', TSize.Create(76, 76));
  Sizes.Add('iPad_AppIcon144', TSize.Create(144, 144));
  Sizes.Add('iPad_AppIcon152', TSize.Create(152, 152));

  Sizes.Add('iPad_Launch768', TSize.Create(768, 1004));
  Sizes.Add('iPad_Launch768x1024', TSize.Create(768, 1024));
  Sizes.Add('iPad_Launch1024', TSize.Create(1024, 748));
  Sizes.Add('iPad_Launch1024x768', TSize.Create(1024, 768));
  Sizes.Add('iPad_Launch1536', TSize.Create(1536, 2008));
  Sizes.Add('iPad_Launch1536x2048', TSize.Create(1536, 2048));
  Sizes.Add('iPad_Launch2048', TSize.Create(2048, 1496));
  Sizes.Add('iPad_Launch2048x1536', TSize.Create(2048, 1536));

  Sizes.Add('iPad_SpotLight40', TSize.Create(40, 40));
  Sizes.Add('iPad_SpotLight50', TSize.Create(50, 50));
  Sizes.Add('iPad_SpotLight80', TSize.Create(80, 80));
  Sizes.Add('iPad_SpotLight100', TSize.Create(100, 100));

  Sizes.Add('iPad_Setting29', TSize.Create(29, 29));
  Sizes.Add('iPad_Setting58', TSize.Create(58, 58));





end;

function TPredefinedSizes.GetSize(const tag: string): TSize;
begin
  if not Sizes.TryGetValue(tag, Result) then raise Exception.Create('Size unknown: ' + tag);

end;

end.
