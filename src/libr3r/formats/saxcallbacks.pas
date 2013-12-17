unit SaxCallbacks;

{$CALLING cdecl}

interface

uses
  Expas;

procedure ElementStarted(user_data: Pointer; name: PChar; attrs: PPXML_Char);
procedure ElementEnded(user_data: Pointer; name: PChar);
procedure CharactersReceived(ctx: Pointer; ch: PChar; len: integer);

{$IFDEF EXPAT_1_1}
procedure CdataSectionLimit(userData: Pointer);
{$ENDIF}

{$IFDEF EXPAT_2_0}
procedure XmlDeclarationReceived(userData: Pointer; version, encoding: PChar; standalone: integer);
{$ELSE}
{$IFDEF EXPAT_1_0}
function UnknownEncodingDetected(encodingHandlerData:pointer; name:PChar; info:PXML_Encoding):integer;
{$ENDIF}
{$ENDIF}

function DataToUTF8(const InStr: String; const Encoding: PChar; var Converted: Boolean): PChar;

implementation

uses
{$IFDEF USE_ICONV}
  Iconv, RProp,
{$ENDIF}
{$IFNDEF EXPAT_2_0}
  LibR3RStrings, RMessage,
{$ENDIF}
  RStrings, SysUtils, Xml;

procedure SplitName(const Name: String; var ElemName, NSURI: String);
var
  Index: PtrUInt;
begin
  Index := Pos(NameSpaceSeparator, Name);
  if Index <> 0 then
  begin
    NSURI := Name[1..Index - 1];
    ElemName := Name[Index + 1..Length(Name)];
  end
  else
  begin
    ElemName := Name;
    NSURI := '';
  end;
end;

procedure ElementStarted(user_data: Pointer; name: PChar; attrs: PPXML_Char);
var
  attr: String;
  Elem: PXmlElement;
  patt: PXmlAttr;
begin
  with TXmlFeed(user_data) do
  begin
    New(Elem);
    New(Elem^.Attributes, Init);
    WriteStr(attr, name);
    SplitName(attr, Elem^.Name, Elem^.NameSpace);
    Elem^.Content := '';
    Elem^.Depth := Depth;
{$IFDEF EXPAT_1_1}
    Elem^.InCdataSection := false;
{$ENDIF}

    if Assigned(attrs) then
    begin
      while Assigned(attrs^) do
      begin
        New(patt);
        WriteStr(attr, attrs^);
        SplitName(attr, patt^.Name, patt^.NameSpace);
        WriteStr(patt^.Value, (attrs + 1)^);

        if patt^.NameSpace = '' then
        begin
          patt^.NameSpace := Elem^.NameSpace;
        end;
        Elem^.Attributes^.Add(patt);

        attr := patt^.Name;
        if attr = 'base' then
        begin
          Elem^.Base := patt^.Value;
        end
        else if attr = 'lang' then
        begin
          Elem^.Lang := patt^.Value;
        end;

        Inc(attrs, 2);
      end;
    end;

    if Elem^.Name <> '' then
    begin
      Inc(Depth);
      FElemList^.Add(Elem);
      SendItem;
    end;
  end;
end;

procedure ElementEnded(user_data: Pointer; name: PChar);
var
  Elem: PXmlElement;
  Ename: String;
begin
  with TXmlFeed(user_data) do
  begin
    if FElemList^.Count > 0 then
    begin
      WriteStr(Ename, name);
      Elem := FElemList^.GetNth(FElemList^.Count - 1);
      SplitName(Ename, Elem^.Name, Elem^.NameSpace);
    end;

    if Elem^.Name <> '' then
    begin
      Dec(Depth);
      Elem^.Name := '';
    end;
  end;
end;

procedure CharactersReceived(ctx: Pointer; ch: PChar; len: integer);
const
  Stage: 1..2 = 1;
var
  Elem: PXmlElement;
  enh: String;
  loff: 0..1;
  nl: Boolean;
begin
  loff := Ord(ch[len-1] = #9);
  nl := true;
  WriteStr(enh, ch[0..len - (loff + 1)]);

  { De-expand entities that cause problems with embedded HTML }
  if (len = 1) and (Length(enh) > 0) then
  begin
    nl := false;
    Stage := 2;
    case enh[1] of
      '&':
      begin
        enh := '&amp;'
      end;
      '>':
      begin
        enh := '&gt;';
      end;
      '<':
      begin
        enh := '&lt;';
      end;
    end;
  end;

  with TXmlFeed(ctx) do
  begin
    if FElemList^.Count > 0 then
    begin
      Elem := FElemList^.GetNth(FElemList^.Count - 1);

      nl := nl and (Length(Elem^.Content) > 0);
      if nl then
      begin
        if Stage = 1 then
        begin
          Elem^.Content := Elem^.Content + ' ';
        end;
        Stage := 1;
      end;
      Elem^.Content := Elem^.Content + enh;
      SendItem;
    end;
  end;
end;

{$IFDEF EXPAT_1_1}
procedure CdataSectionLimit(userData: Pointer);
var
  Elem: PXmlElement;
begin
  with TXmlFeed(userData) do
  begin
    if FElemList^.Count > 0 then
    begin
      Elem := FElemList^.GetNth(FElemList^.Count - 1);
      Elem^.InCdataSection := not Elem^.InCdataSection;
    end;
  end;
end;
{$ENDIF}

{$IFDEF EXPAT_2_0}
procedure XmlDeclarationReceived(userData: Pointer; version, encoding: PChar; standalone: integer);
begin
{$IFDEF USE_ICONV}
  SetProp('charset', StrToPCharAlloc('UTF-8'));
{$ENDIF}
  TXmlFeed(userData).FEncoding := encoding;
end;
{$ELSE}
{$IFDEF EXPAT_1_0}
function UnknownEncodingDetected(encodingHandlerData:pointer; name:PChar; info:PXML_Encoding):integer;
var
  Message: String;
begin
  WriteStr(Message, name);
  CallMessageEvent(TXmlFeed(encodingHandlerData), true, UnknownEncoding, Message);
  UnknownEncodingDetected := 0;
end;
{$ENDIF}
{$ENDIF}

function DataToUTF8(const InStr: String; const Encoding: PChar; var Converted: Boolean): PChar;
var
{$IFDEF USE_ICONV}
  cd: iconv_t;
{$IFDEF USE_LIBICONV}
  i: integer;
{$ENDIF}
  inbuf, outbuf: PChar;
  inbytesleft, outbytesleft: size_t;
{$ENDIF}
  outstr: PChar;
begin
  Converted := false;
{$IFDEF USE_ICONV}
  if (Encoding <> nil) and (StrIComp('UTF-8', Encoding) <> 0) then
  begin
    cd := iconv_open('UTF-8', Encoding);
    if cd <> iconv_t(-1) then
    begin
  {$IFDEF USE_LIBICONV}
      i := 1;
      iconvctl(cd, ICONV_SET_TRANSLITERATE, @i);
  {$ENDIF}
      if outstr <> nil then
      begin
        Converted := true;
        inbuf := StrToPChar(InStr);
        inbytesleft := StrLen(inbuf) + 1;
        outbytesleft := inbytesleft * 4;
        GetMem(outstr, outbytesleft);
        outbuf := outstr;
        if iconv_convert(cd, @inbuf, @inbytesleft, @outbuf, @outbytesleft) = iconv_convert_error then
        begin
          outstr := StrToPChar(InStr);
        end;
      end;
    end;
    iconv_close(cd);
  end
  else
  begin
    outstr := StrToPChar(InStr);
  end;
{$ELSE}
  outstr := StrToPChar(InStr);
{$ENDIF}
  DataToUTF8 := outstr;
end;

end.
