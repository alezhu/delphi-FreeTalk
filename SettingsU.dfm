object fmSettings: TfmSettings
  Left = 453
  Top = 218
  BorderStyle = bsDialog
  Caption = 'Настройки'
  ClientHeight = 130
  ClientWidth = 333
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object cbAutoStart: TCheckBox
    Left = 8
    Top = 8
    Width = 233
    Height = 17
    Caption = 'Запуск вместе с Windows'
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 72
    Top = 102
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    TabOrder = 1
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 184
    Top = 102
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Отмена'
    TabOrder = 2
    Kind = bkCancel
  end
end
