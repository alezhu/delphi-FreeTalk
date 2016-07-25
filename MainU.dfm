object fmMain: TfmMain
  Left = 980
  Top = 143
  Width = 184
  Height = 442
  Caption = 'FreeTalk'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefaultPosOnly
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 0
    Top = 390
    Width = 109
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    Caption = '����'
    TabOrder = 0
    OnClick = Button1Click
  end
  object lbContactList: TListBox
    Left = 0
    Top = 25
    Width = 176
    Height = 368
    Anchors = [akLeft, akTop, akRight, akBottom]
    ExtendedSelect = False
    ItemHeight = 13
    Style = lbOwnerDrawFixed
    TabOrder = 1
    OnDblClick = lbContactListDblClick
    OnDrawItem = lbContactListDrawItem
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 176
    Height = 25
    Caption = 'ToolBar1'
    EdgeBorders = []
    Flat = True
    Images = ImageList1
    TabOrder = 2
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Action = acToggleFavorites
      AllowAllUp = True
      Style = tbsCheck
    end
  end
  object pmMain: TPopupMenu
    AutoPopup = False
    Left = 40
    Top = 288
    object N4: TMenuItem
      Caption = '������������'
      object N5: TMenuItem
        Action = acEditUsers
      end
      object N1: TMenuItem
        Action = acImportFVR
      end
    end
    object N6: TMenuItem
      Action = acSettings
    end
    object N7: TMenuItem
      Action = acShowLog
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object N2: TMenuItem
      Action = acExit
    end
    object testRecive1: TMenuItem
      Action = acTestReceve
    end
  end
  object ActionList1: TActionList
    Left = 80
    Top = 288
    object acExit: TAction
      Category = 'Main'
      Caption = '�����'
      OnExecute = acExitExecute
    end
    object acImportFVR: TAction
      Category = 'Main'
      Caption = '������'
      OnExecute = acImportFVRExecute
    end
    object acTestReceve: TAction
      Caption = 'testRecive'
      OnExecute = acTestReceveExecute
    end
    object acEditUsers: TAction
      Caption = '���������...'
      OnExecute = acEditUsersExecute
    end
    object acSettings: TAction
      Caption = '���������'
      OnExecute = acSettingsExecute
    end
    object acShowLog: TAction
      Caption = '�������� ���'
      OnExecute = acShowLogExecute
    end
    object acToggleFavorites: TAction
      Caption = 'acToggleFavorites'
      Hint = '������ ��������� / ��� ������������'
      ImageIndex = 0
      OnExecute = acToggleFavoritesExecute
    end
  end
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 120
    Top = 288
  end
  object ImageList1: TImageList
    Left = 64
    Top = 232
    Bitmap = {
      494C010101000400040010001000FFFFFFFFFF00FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000005252520045454500454545004545450045454500525252000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000005B5B
      5B002B49750034699E004892CE0061A9EA0061A9EA004892CE0034699E002B49
      75005B5B5B000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000060616A002B49
      75004E96E6007BBAFA0093D1FE0099D7FE0099D7FE0093D1FE007EC0F9004E96
      E6002B49750060616A0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000002B4975004384
      CE0073ADEF0086C4FE0090CEFE0099D7FE0099D7FE0093D1FE0086C4FE0076B2
      F4004388D3002B49750000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000545474001C57A6005591
      D2006AA6E6007BBAFA0086C4FE0086C4FE0086C4FE0086C4FE007BBAFA006CA7
      EC005995D6001C57A60054547400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000303061002B63AE004887
      CD005998DC006AA6E60076B2F4007BB8F6007BB8F60079B4F5006CA7EC005998
      DC004F8ACE002B63AE0030306100000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000010104E003260AA003875
      BB004887CD005995D60067A3E00067A3E00067A3E00067A3E0005C97DA004887
      CD003875BB003260AA0010104E00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000010104E00344E9A002061
      AD002F71B900437FC3004F8ACE004F8ACE004F8ACE004F8ACE004481C7002F71
      B9002061AD00344E9A0010104E00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000001E1E3900353785001D48
      98001C57A6002D6AAB003875BB003875BB003875BB003875BB002B6BB1001C57
      A6001D489800353785001E1E3900000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000004A4A4A00303061003537
      85002D539B002D6AAB003970AD003970AD003970AD003970AD002D6AAB002D53
      9B0035378500303061004A4A4A00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000282829005454
      74007373A600959EC6009CADCE009CADCE009CADCE009CADCE00959EC6007373
      A600545474002828290000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000006E6E6E003D3D
      3D0090909D00C9C9D500E5E5ED00E5E5ED00E5E5ED00E5E5ED00C9C9D5009090
      9D003D3D3D006E6E6E0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000006B6B
      6B003D3D3D008D8D8D00BBBBBB00CDCDCD00CDCDCD00BBBBBB008D8D8D003D3D
      3D006B6B6B000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000005B5B5B00282829000B0B0B000B0B0B00282829005B5B5B000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFF000000000000F81F000000000000
      E007000000000000C003000000000000C0030000000000008001000000000000
      8001000000000000800100000000000080010000000000008001000000000000
      8001000000000000C003000000000000C003000000000000E007000000000000
      F81F000000000000FFFF000000000000}
  end
end
