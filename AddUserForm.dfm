object fmUsers: TfmUsers
  Left = 276
  Top = 178
  Width = 465
  Height = 585
  Caption = 'Пользователи'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 216
    Top = 0
    Width = 241
    Height = 558
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 60
      Height = 13
      Caption = 'Имя в сети:'
    end
    object Label2: TLabel
      Left = 10
      Top = 40
      Width = 58
      Height = 13
      Caption = 'Псевдоним'
    end
    object Label3: TLabel
      Left = 10
      Top = 64
      Width = 25
      Height = 13
      Caption = 'Цвет'
    end
    object Shape1: TShape
      Left = 80
      Top = 64
      Width = 121
      Height = 21
    end
    object edAddress: TEdit
      Left = 80
      Top = 8
      Width = 121
      Height = 21
      TabOrder = 0
      OnChange = edAddressChange
    end
    object edNick: TEdit
      Left = 80
      Top = 32
      Width = 121
      Height = 21
      TabOrder = 1
      OnChange = edNickChange
    end
    object bbAddr: TBitBtn
      Left = 208
      Top = 8
      Width = 27
      Height = 25
      TabOrder = 2
    end
    object Button1: TButton
      Left = 8
      Top = 528
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'ОК'
      Default = True
      ModalResult = 1
      TabOrder = 3
    end
    object Button2: TButton
      Left = 128
      Top = 528
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 4
    end
    object btAddUser: TButton
      Left = 160
      Top = 104
      Width = 75
      Height = 25
      Action = acAddUser
      TabOrder = 5
    end
    object Button4: TButton
      Left = 160
      Top = 136
      Width = 75
      Height = 25
      Action = acDelUser
      TabOrder = 6
    end
  end
  object lbUsers: TCheckListBox
    Left = 16
    Top = 80
    Width = 161
    Height = 385
    ItemHeight = 16
    Style = lbOwnerDrawFixed
    TabOrder = 1
    OnClick = lbUsersClick
    OnDrawItem = lbUsersDrawItem
  end
  object ColorDialog1: TColorDialog
    Ctl3D = True
    Options = [cdFullOpen, cdShowHelp, cdSolidColor, cdAnyColor]
    Left = 56
    Top = 8
  end
  object ActionList1: TActionList
    Left = 296
    Top = 208
    object acAddUser: TAction
      Caption = 'Добавить'
      OnExecute = acAddUserExecute
    end
    object acDelUser: TAction
      Caption = 'Удалить'
      OnExecute = acDelUserExecute
      OnUpdate = acDelUserUpdate
    end
    object acUp: TAction
      Caption = 'Вверх'
    end
    object acDown: TAction
      Caption = 'Вниз'
    end
  end
end
