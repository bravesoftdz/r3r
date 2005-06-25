unit LocalFile;

interface

uses
  RSock, FeedItem;

type
  TLocalFile = class(TRSock)
  private
    FFileHandle: Text;
    FFileName: String;
  protected
    function GetLine: String; override;
  public
    constructor Create(FileName: String);
    destructor Destroy; override;
    procedure Execute; override;
    function ParseItem(var Item: TFeedItem): Boolean; override;
  end;

implementation

uses
  Feed, SysUtils;

constructor TLocalFile.Create(FileName: String);
begin
  Read;
  FFileName := FileName;
end;

destructor TLocalFile.Destroy;
begin
  Close(FFileHandle);
end;

procedure TLocalFile.Execute;
begin
  Assign(FFileHandle, FFileName);
  Reset(FFileHandle);
end;

function TLocalFile.GetLine: String;
begin
  if Eof(FFileHandle) then
  begin
    Result := SockEof;
  end
  else
  begin
    ReadLn(FFileHandle, Result);
  end;
end;

function TLocalFile.ParseItem(var Item: TFeedItem): Boolean;
var
  FileExt: String;
begin
  FileExt := ExtractFileExt(FFileName);

  if FileExt = '.esf' then
  begin
    FeedType := ftEsf;
  end
  else if FileExt = '.r3' then
  begin
    FeedType := ftRss3;
  end
  else
  begin
    FeedType := ftUnknown;
  end;

  Result := inherited ParseItem(Item);
end;

end.