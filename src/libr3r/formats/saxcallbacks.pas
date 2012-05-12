unit SaxCallbacks;

{$CALLING cdecl}
{$POINTERMATH ON}

interface

uses
  Expas;

procedure ElementStarted(user_data: Pointer; name: PChar; attrs: PPChar);
procedure ElementEnded(user_data: Pointer; name: PChar);
procedure CharactersReceived(ctx: Pointer; ch: PChar; len: integer);
procedure InstructionReceived(userData: Pointer; target, data: PChar);

implementation

uses
{$IFDEF USE_ICONV}
  RProp, RStrings,
{$ENDIF}
  StrTok, SysUtils, Xml;

procedure SplitName(const Name: String; var QName, NameSpace: String);
var
  List: TStringsList;
begin
  List := Split(Name, NameSpaceSeparator);
  if List.Length = 2 then
  begin
    NameSpace := List.Strings[0];
    QName := List.Strings[1];
  end
  else if List.Length = 1 then
  begin
    NameSpace := '';
    QName := List.Strings[0];
  end;
end;

procedure ElementStarted(user_data: Pointer; name: PChar; attrs: PPChar);
var
  attr: String;
  Elem: PXmlElement;
  i: word;
begin
  i := 0;

  with TXmlFeed(user_data) do
  begin
    New(Elem);
    SplitName(StrPas(name), Elem^.Name, Elem^.NameSpace);
    Elem^.Content := '';
    Elem^.Depth := Depth;

    if Assigned(attrs) then
    begin
      while Assigned(attrs^) do
      begin
        attr := StrPas(attrs^);
        attrs^ := PChar(attr);

        SplitName(attr, Elem^.Attributes[i].Name, Elem^.Attributes[i].NameSpace);
        attr := Elem^.Attributes[i].Name;
        if Elem^.Attributes[i].NameSpace = '' then
        begin
          Elem^.Attributes[i].NameSpace := Elem^.NameSpace;
        end;

        if attr = 'base' then
        begin
          Elem^.Base := StrPas((attrs + 1)^);
        end
        else if attr = 'lang' then
        begin
          Elem^.Lang := StrPas((attrs + 1)^);
        end
        else if i < 11 then
        begin
          Elem^.Attributes[i].Value := StrPas((attrs + 1)^);
          Inc(i);
        end;

        Inc(attrs, 2);
      end;
    end;

    Inc(Depth);
    if Elem^.Name <> '' then
    begin
      FElemList^.Add(Elem);
      SendItem;
    end;
  end;
end;

procedure ElementEnded(user_data: Pointer; name: PChar);
var
  Elem: PXmlElement;
begin
  with TXmlFeed(user_data) do
  begin
    if FElemList^.Count > 0 then
    begin
      Elem := FElemList^.GetNth(FElemList^.Count - 1);
      SplitName(StrPas(name), Elem^.Name, Elem^.NameSpace);
    end;

    if Elem^.Name <> '' then
    begin
      Dec(Depth);
    end;
  end;
end;

procedure CharactersReceived(ctx: Pointer; ch: PChar; len: integer);
var
  Elem: PXmlElement;
  enh: String;
begin
  enh := Copy(StrPas(ch), 1, len);

  with TXmlFeed(ctx) do
  begin
    if FElemList^.Count > 0 then
    begin
      Elem := FElemList^.GetNth(FElemList^.Count - 1);
      Elem^.Content := Elem^.Content + enh;
      SendItem;
    end;
  end;
end;

procedure InstructionReceived(userData: Pointer; target, data: PChar);
{$IFDEF USE_ICONV}
var
  Priv: String;
  PrivStart: word;
{$ENDIF}
begin
{$IFDEF USE_ICONV}
  if StrComp(target, 'xml') <> 0 then
  begin
    if GetProp('charset') = nil then
    begin
      Priv := StrPas(data);
      PrivStart := Pos('encoding=', Priv);
      if PrivStart <> 0 then
      begin
        Delete(Priv, 1, PrivStart + Length('encoding='));
        PrivStart := Pos('''', Priv);
        Delete(Priv, PrivStart, Length(Priv) - PrivStart + Length(''''));
        PrivStart := Pos('"', Priv);
        Delete(Priv, PrivStart, Length(Priv) - PrivStart + Length('"'));
        SetProp('charset', StrToPChar(Priv));
      end;
    end;
  end;
{$ENDIF}
end;

end.
