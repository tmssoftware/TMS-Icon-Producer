unit UIconData;

interface
type
  TDevice = (iPhone, iPad);
  TiOS = (iOS5, iOS6, iOS7, iOS8);
  TiOSSet = set of TiOS;
  TIconSizes = (Size1, Size2, Size3);
  TIconSizesSet = Set of TIconSizes;

  TIconInstance = record
  public
    Name: string;
    Width: Integer;
    Height: Integer;
    Sizes: TIconSizesSet;
    Device: TDevice;
    iOS: TiOSSet;
  end;


const
  iOSIcons: array[0..10] of TIconInstance =
  (
       //iphone ios5
      (Name: 'Spotlight and Settings'; Width: 29; Height: 29; Sizes: [Size1, Size2]; Device: iPhone; iOS: [iOS5..iOS6]),
      (Name: 'App'; Width: 57; Height: 57; Sizes: [Size1, Size2]; Device: iPhone; iOS: [iOS5..iOS6]),

      //iphone ios7
      (Name: 'Settings'; Width: 29; Height: 29; Sizes: [Size2, Size3]; Device: iPhone; iOS: [iOS7..iOS8]),
      (Name: 'Spotlight'; Width: 40; Height: 40; Sizes: [Size2, Size3]; Device: iPhone; iOS: [iOS7..iOS8]),
      (Name: 'App'; Width: 60; Height: 60; Sizes: [Size2, Size3]; Device: iPhone; iOS: [iOS7..iOS8]),

      //iPad ios5
      (Name: 'Settings'; Width: 29; Height: 29; Sizes: [Size1, Size2]; Device: iPad; iOS: [iOS5..iOS6]),
      (Name: 'Spotlight'; Width: 50; Height: 50; Sizes: [Size1, Size2]; Device: iPad; iOS: [iOS5..iOS6]),
      (Name: 'App'; Width: 72; Height: 72; Sizes: [Size1, Size2]; Device: iPad; iOS: [iOS5..iOS6]),

      //iPad ios7
      (Name: 'Settings'; Width: 29; Height: 29; Sizes: [Size1, Size2]; Device: iPad; iOS: [iOS7..iOS8]),
      (Name: 'Spotlight'; Width: 40; Height: 40; Sizes: [Size1, Size2]; Device: iPad; iOS: [iOS7..iOS8]),
      (Name: 'App'; Width: 76; Height: 76; Sizes: [Size1, Size2]; Device: iPad; iOS: [iOS7..iOS8])
  );

  IOSLaunch: array[0..10] of TIconInstance =
  (
       //iPhone ios5
      (Name: 'Portrait'; Width: 320; Height: 480; Sizes: [Size1, Size2]; Device: iPhone; iOS: [iOS5..iOS6]),
      (Name: 'Retina 4'; Width: 640; Height: 1136; Sizes: [Size1]; Device: iPhone; iOS: [iOS5..iOS6]),

      //iPhone ios7
      (Name: 'Portrait'; Width: 320; Height: 480; Sizes: [Size2]; Device: iPhone; iOS: [iOS7..iOS8]),
      (Name: 'Portrait Retina 4'; Width: 640; Height: 1136; Sizes: [Size1]; Device: iPhone; iOS: [iOS7..iOS8]),

      //iPhone ios8
      (Name: 'Portrait Retina HD 4.7'; Width: 750; Height: 1334; Sizes: [Size1]; Device: iPhone; iOS: [iOS8]),
      (Name: 'Portrait Retina HD 5.5'; Width: 1242; Height: 2208; Sizes: [Size1]; Device: iPhone; iOS: [iOS8]),
      (Name: 'Landscape Retina HD 5.5'; Width: 2208; Height: 1242; Sizes: [Size1]; Device: iPhone; iOS: [iOS8]),

      //iPad ios5 / 8
      (Name: 'Portrait'; Width: 768; Height: 1024; Sizes: [Size1, Size2]; Device: iPad; iOS: [iOS5..iOS8]),
      (Name: 'Portrait without status bar'; Width: 768; Height: 1004; Sizes: [Size1, Size2]; Device: iPad; iOS: [iOS5..iOS6]),
      (Name: 'Landscape'; Width: 1024; Height: 768; Sizes: [Size1, Size2]; Device: iPad; iOS: [iOS5..iOS8]),
      (Name: 'Landscape without status bar'; Width: 1024; Height: 748; Sizes: [Size1, Size2]; Device: iPad; iOS: [iOS5..iOS6])

  );


implementation

end.
