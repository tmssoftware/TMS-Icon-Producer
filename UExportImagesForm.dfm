object ExportImagesForm: TExportImagesForm
  Left = 0
  Top = 0
  Caption = 'Icon Spread'
  ClientHeight = 530
  ClientWidth = 713
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object OptionsPanel: TPanel
    Left = 0
    Top = 147
    Width = 713
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object edOptimizePng: TCheckBox
      Left = 16
      Top = 38
      Width = 209
      Height = 17
      Caption = 'Optimize pngs (slow)'
      TabOrder = 0
    end
    object cbGenerateIphone: TCheckBox
      Left = 16
      Top = 6
      Width = 178
      Height = 17
      Caption = 'Generate iPhone files'
      TabOrder = 1
    end
    object cbGenerateIpad: TCheckBox
      Left = 200
      Top = 6
      Width = 209
      Height = 17
      Caption = 'Generate iPad files'
      TabOrder = 2
    end
    object cbGenerateAndroid: TCheckBox
      Left = 384
      Top = 6
      Width = 169
      Height = 17
      Caption = 'Generate Android files'
      TabOrder = 3
    end
    object cbOnlyRequired: TCheckBox
      Left = 200
      Top = 38
      Width = 209
      Height = 17
      Caption = 'Only required icons'
      TabOrder = 4
    end
    object PanelBkColor: TPanel
      Left = 568
      Top = 1
      Width = 137
      Height = 56
      Caption = 'Back color'
      Color = clInfoBk
      ParentBackground = False
      TabOrder = 5
      OnClick = PanelBkColorClick
    end
    object cbCreateNewFiles: TCheckBox
      Left = 384
      Top = 38
      Width = 178
      Height = 17
      Caption = 'Create new files'
      TabOrder = 6
    end
  end
  object LogFrame: TPanel
    Left = 0
    Top = 252
    Width = 713
    Height = 237
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object SplitterLogs1: TSplitter
      Left = 448
      Top = 0
      Width = 8
      Height = 237
      Align = alRight
      ResizeStyle = rsUpdate
      ExplicitLeft = 462
      ExplicitTop = -6
      ExplicitHeight = 269
    end
    object LogMemoMain: TMemo
      Left = 0
      Top = 0
      Width = 448
      Height = 237
      Align = alClient
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object Log2Panel: TPanel
      Left = 456
      Top = 0
      Width = 257
      Height = 237
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object Splitter1: TSplitter
        Left = 0
        Top = 112
        Width = 257
        Height = 8
        Cursor = crVSplit
        Align = alBottom
        ResizeStyle = rsUpdate
        ExplicitTop = 149
      end
      object LogMemoOptimize: TMemo
        Left = 0
        Top = 120
        Width = 257
        Height = 117
        Align = alBottom
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object LogMemoResize: TMemo
        Left = 0
        Top = 0
        Width = 257
        Height = 112
        Align = alClient
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
  end
  inline LogCaption: TCaptionFrame
    Left = 0
    Top = 220
    Width = 713
    Height = 32
    Align = alTop
    Color = clActiveCaption
    ParentBackground = False
    ParentColor = False
    TabOrder = 2
    ExplicitTop = 220
    ExplicitWidth = 713
    inherited Caption: TLabel
      Width = 27
      Caption = 'Log'
      ExplicitWidth = 27
    end
  end
  object CommandsPanel: TPanel
    Left = 0
    Top = 489
    Width = 713
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    DesignSize = (
      713
      41)
    object GoButton: TButton
      Left = 528
      Top = 6
      Width = 82
      Height = 25
      Action = ActionGo
      Anchors = [akTop, akRight]
      Default = True
      TabOrder = 0
    end
    object CancelButton: TButton
      Left = 616
      Top = 6
      Width = 82
      Height = 25
      Action = ActionExit
      Anchors = [akTop, akRight]
      Cancel = True
      ModalResult = 2
      TabOrder = 1
    end
  end
  inline ConfigurationCaption: TCaptionFrame
    Left = 0
    Top = 0
    Width = 713
    Height = 32
    Align = alTop
    Color = clActiveCaption
    ParentBackground = False
    ParentColor = False
    TabOrder = 4
    ExplicitWidth = 713
    inherited Caption: TLabel
      Width = 106
      Caption = 'Configuration'
      ExplicitWidth = 106
    end
  end
  object ConfigurationPanel: TPanel
    Left = 0
    Top = 32
    Width = 713
    Height = 115
    Align = alTop
    BevelEdges = []
    BevelOuter = bvNone
    TabOrder = 5
    DesignSize = (
      713
      115)
    object edMasterIconFolder: TLabeledEdit
      Left = 16
      Top = 27
      Width = 608
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 135
      EditLabel.Height = 13
      EditLabel.Caption = 'Folder with the master icons'
      TabOrder = 0
      OnChange = edMasterIconFolderChange
    end
    object btnOpenMasterInExplorer: TButton
      Left = 630
      Top = 27
      Width = 75
      Height = 21
      Action = ActionOpenMasterInExplorer
      Anchors = [akTop, akRight]
      TabOrder = 1
    end
    object btnOpenGeneratedInExplorer: TButton
      Left = 630
      Top = 75
      Width = 75
      Height = 21
      Action = ActionOpenGeneratedInExplorer
      Anchors = [akTop, akRight]
      TabOrder = 2
    end
    object edGeneratedIconFolder: TLabeledEdit
      Left = 16
      Top = 75
      Width = 608
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 146
      EditLabel.Height = 13
      EditLabel.Caption = 'Folder for the generated icons'
      TabOrder = 3
      OnChange = edGeneratedIconFolderChange
    end
  end
  object Actions: TActionList
    Left = 376
    object ActionGo: TAction
      Caption = 'Go!'
      OnExecute = ActionGoExecute
    end
    object ActionExit: TAction
      Caption = 'Exit'
      OnExecute = ActionExitExecute
    end
  end
  object ActionsConfig: TActionList
    Left = 438
    object ActionOpenMasterInExplorer: TAction
      Caption = 'E&xplorer'
      OnExecute = ActionOpenMasterInExplorerExecute
    end
    object ActionOpenGeneratedInExplorer: TAction
      Caption = '&Explorer'
      OnExecute = ActionOpenGeneratedInExplorerExecute
    end
  end
  object BackColorDialog: TColorDialog
    Options = [cdFullOpen, cdAnyColor]
    Left = 680
    Top = 120
  end
end
