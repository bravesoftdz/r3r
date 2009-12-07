unit classic; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Menus,
  ComCtrls, Buttons, StdCtrls, LclType, ClassicStrings, LibR3R, Info;

type

  { TR3RForm }

  TR3RForm = class(TForm)
    CloseItem: TMenuItem;
    InfoItem: TMenuItem;
    FeedList: TListView;
    SettingsItem: TMenuItem;
    OpenItem: TMenuItem;
    UriEdit: TEdit;
    GoBtn: TButton;
    DescBox: TGroupBox;
    FileMenu: TMenuItem;
    ToolsMenu: TMenuItem;
    HelpMenu: TMenuItem;
    R3RMenu: TMainMenu;
    StatusBar: TStatusBar;
    procedure Created(Sender: TObject);
    procedure GoBtnClick(Sender: TObject);
    procedure InfoMenuClick(Sender: TObject);
    procedure OpenItemClick(Sender: TObject);
    procedure CloseItemClick(Sender: TObject);
    procedure UriEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
  private
    { private declarations }
    FTopItem: Boolean;
    procedure ParseFeed(const Uri: String);
    procedure ItemParsed(Item: TFeedItem);
    procedure GotMessage(Sender: TObject; Error: Boolean; MessageName: String);
  public
    { public declarations }
  end; 

var
  R3RForm: TR3RForm;

implementation

{ TR3RForm }

procedure TR3RForm.Created(Sender: TObject);
begin
  FileMenu.Caption := FileMnuCap;
    OpenItem.Caption := OpenItmCap;
    CloseItem.Caption := CloseItmCap;
  ToolsMenu.Caption := ToolsMnuCap;
    SettingsItem.Caption := SettingsItmCap;
  HelpMenu.Caption := HelpMnuCap;
    InfoItem.Caption := InfoItmCap;

  FeedList.Columns[0].Width := 100;
  FeedList.Columns[0].Caption := NameCol;

  FeedList.Columns[1].Width := 200;
  FeedList.Columns[1].Caption := TitleCol;

  FeedList.Columns[2].Width := 67;
  FeedList.Columns[2].Caption := SubjCol;

  FeedList.Columns[3].Caption := CreatedCol;

  GoBtn.Caption := Go;
end;

procedure TR3RForm.GoBtnClick(Sender: TObject);
begin
  ParseFeed(UriEdit.Text);
end;

procedure TR3RForm.InfoMenuClick(Sender: TObject);
begin
  ShowMessage('R3R ' + Version + ' (' + Os + ')');
end;

procedure TR3RForm.OpenItemClick(Sender: TObject);
var
  OpenDlg: TOpenDialog;
begin
  OpenDlg := TOpenDialog.Create(Self);
  OpenDlg.Execute;
  ParseFeed(OpenDlg.FileName);
end;

procedure TR3RForm.CloseItemClick(Sender: TObject);
begin
  Close;
end;

procedure TR3RForm.UriEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    ParseFeed((Sender as TEdit).Text);
  end;
end;

procedure TR3RForm.ParseFeed(const Uri: String);
var
  Lib: TLibR3R;
begin
  FTopItem := true;
  Lib := TLibR3R.Create(Uri);
  Lib.OnItemParsed := @ItemParsed;
  Lib.OnMessage := @GotMessage;
  Lib.Parse;
  Lib.Free;
end;

procedure TR3RForm.ItemParsed(Item: TFeedItem);
begin
  with FeedList.Items.Add do
  begin
    if not FTopItem then
    begin
      SubItems.Add(Item.Title);
    end
    else
    begin
      Caption := Item.Title;
      FTopItem := false;
      
      SubItems.Add('');
    end;

    if Item.Subject <> '' then
    begin
      SubItems.Add(Item.Subject)
    end
    else
    begin
      SubItems.Add(EmptyField)
    end;

    if Item.Created <> '' then
    begin
      SubItems.Add(Item.Created)
    end
    else
    begin
      SubItems.Add(EmptyField)
    end;
  end;
end;

procedure TR3RForm.GotMessage(Sender: TObject; Error: Boolean; MessageName: String);
begin
  StatusBar.SimpleText := MessageName;
end;

initialization
{$I classic.lrs}

end.
