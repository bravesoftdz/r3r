unit ItemCallbacks;

interface

uses
  FeedItem;

type
  TItemCallback = procedure(const Item: TFeedItem);

procedure RegisterItemCallback(const cb: TItemCallback);
procedure FreeItemCallback;
procedure CallItemCallback(Item: TFeedItem);

implementation

{ For some reason, using AnsiString causes a memory leak }
{$H-}

uses
  HttpCache, RFilter, RProp, RSettings;

procedure RegisterItemCallback(const cb: TItemCallback);
begin
  SetProp('item-callback', @cb);
end;

procedure FreeItemCallback;
begin
  RemoveProp('item-callback');
end;

procedure CallItemCallback(Item: TFeedItem);
const
  LastTitle: String = '';
var
  cb: TItemCallback;
begin
  cb := TItemCallback(GetProp('item-callback'));
  if Assigned(cb) then
  begin
    if Settings.GetBoolean('use-filters') then
    begin
      FilterItem(Item);
    end;

    if (Item.Id <> '') and Assigned(CurrentCache) then
    begin
      CurrentCache.WriteData(Item.Id, cdtIds);
    end;

    if (Item.Title <> '') and (Item.Title <> LastTitle) then
    begin
      Item.Translate;
      cb(Item);
      LastTitle := Item.Title;
      Item.Clear;
    end
  end
end;

end.
