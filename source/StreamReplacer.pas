unit StreamReplacer;

interface

uses
  Types,
  SysUtils,
  Classes,
  
  Int64LinkedList;

type
  TStreamReplacerSearchResult = record
    SoughtIndex, StreamPosition: Integer;
  end;

{$Include g-\StreamReplacerSearchResultLinkedListFace.inc}

type
  { TStreamReplacer }
  TStreamReplacer = class
  protected
    var
      FSought: TStringDynArray;
      FTables: array of TIntegerDynArray;
      FFound: PStreamReplacerSearchResultLinkedList;
      FInput: TStream;
    type
      TReplacer = procedure(const aIndex: Integer; const aOutput: TStream) of object;
    procedure WriteI(const aOutput: TStream; const aReplacer: TReplacer);
    procedure BuildTables;
    procedure SearchThis(
      var aTail: PStreamReplacerSearchResultLinkedList;
      const aIndex: Integer
    );
    procedure AppendSearchResult(
      var aTail: PStreamReplacerSearchResultLinkedList;
      const aSoughtIndex: Integer;
      const aStreamPosition: Int64); inline;
    procedure SearchSought;
    procedure ReleaseDynamicStructures;
    procedure WriteDebugLine(const aString: string);
  public
    constructor Create(const aInput: TStream; const aSearch: TStringDynArray);
    procedure Search;
    procedure Write(const aOutput: TStream; const aReplacer: TReplacer);
    destructor Destroy; override;
  end;

implementation

{$Include g-\StreamReplacerSearchResultLinkedListImpl.inc}
{$Include g-\SortStreamReplacerSearchResultLinkedListImplementation.inc}

function CreateKMPTable(w: string): TIntegerDynArray;
var
  position, cnd: Integer;
begin
  SetLength(result, Length(w));
  position := 2;
  cnd := 0;
  result[0] := -1;
  result[1] := 0;
  while
    position < Length(w)
  do
  begin
    if
      w[position] = w[cnd + 1]
    then
    begin
      Inc(cnd);
      result[position] := cnd;
      Inc(position);
    end
    else
      if
        cnd > 0
      then
        cnd := result[cnd]
      else
      begin
        result[position] := 0;
        Inc(position);
      end;
  end;
end;

function KMPSearchStream(
  const aStartIndex: Int64;
  const w : string;
  const s: TStream;
  const t: TIntegerDynArray
)
  : Int64;
  function getSymbol(const aIndex: Int64): Char;
  begin
    s.Seek(aIndex, soFromBeginning);
    s.ReadBuffer(result, 1);
  end;
var
  i: Integer;
  m: Int64;
begin
  i := 0;
  m := aStartIndex; // (+)
  while
    (m + i) < s.Size
  do
  begin
    if
      w[i + 1] = getSymbol(m + i)
    then
    begin // match
      if i = Length(w) - 1 then
      begin
        result := m;
        exit;
      end;
      i := i + 1;
    end
    else
    begin // mismatch
      m := m + i - T[i];
      if
        T[i] > -1
      then
        i := T[i]
      else
        i := 0;
    end;
  end;
  result := -1;
end;

 { TStreamReplacer }

procedure TStreamReplacer.WriteI(const aOutput: TStream; const aReplacer: TReplacer);
var
  item: TStreamReplacerSearchResult;
  tail: PStreamReplacerSearchResultLinkedList;
begin
  FInput.Seek(0, soFromBeginning);
  tail := FFound;
  while
    Next(tail, item)
  do
  begin
    WriteDebugLine('Position: ' + IntToStr(item.StreamPosition) + '; index: ' + IntToStr(item.SoughtIndex)
      + '; FInput position: ' + IntToStr(FInput.Position));
    if
      item.StreamPosition <> 0
    then
      aOutput.CopyFrom(FInput, item.StreamPosition - FInput.Position);
    WriteDebugLine('FInput position: ' + IntToStr(FInput.Position));
    aReplacer(item.SoughtIndex, aOutput);
    FInput.Seek(Length(FSought[item.SoughtIndex]), soFromCurrent);
  end;
  if FInput.Size <> FInput.Position then
    aOutput.CopyFrom(FInput, FInput.Size - FInput.Position);
end;

procedure TStreamReplacer.BuildTables;
var
  i: Integer;
begin
  SetLength(FTables, Length(FSought));
  for i := 0 to Length(FSought) - 1 do
    FTables[i] := CreateKMPTable(FSought[i]);
end;

procedure TStreamReplacer.SearchThis(
  var aTail: PStreamReplacerSearchResultLinkedList;
  const aIndex: Integer);
var
  position: Int64;
  currentSought: string;
  tail: PInt64LinkedList;
begin
  position := 0;
  currentSought := FSought[aIndex];
  WriteDebugLine('Now searching: ' + currentSought);
  repeat
    position := KMPSearchStream(position, currentSought, FInput, FTables[aIndex]);
    if
      -1 = position
    then
      break;
    WriteDebugLine('Found: ' + IntToStr(position));
    AppendSearchResult(aTail, aIndex, position);
    Inc(position);
  until False;
end;

procedure TStreamReplacer.AppendSearchResult(
  var aTail: PStreamReplacerSearchResultLinkedList;
  const aSoughtIndex: Integer; const aStreamPosition: Int64);
var
  item: TStreamReplacerSearchResult;
begin
  item.SoughtIndex := aSoughtIndex;
  item.StreamPosition := aStreamPosition;
  Append(FFound, aTail, item);
end;

procedure TStreamReplacer.SearchSought;
var
  i: Integer;
  tail: PStreamReplacerSearchResultLinkedList;
begin
  FFound := nil;
  for i := 0 to Length(FSought) - 1 do
    SearchThis(tail, i);
  FFound := SortSearchResults(FFound);
end;

procedure TStreamReplacer.ReleaseDynamicStructures;
var
  i: Integer;
begin
  WriteDebugLine('Now releasing dynamic structures...');
  SetLength(FSought, 0);
  for i := 0 to Length(FTables) - 1 do
    SetLength(FTables[i], 0);
  SetLength(FTables, 0);
  DisposeList(FFound);
end;

procedure TStreamReplacer.WriteDebugLine(const aString: string);
begin
  WriteLn(aString);
end;

// TStreamReplacer public methods 

constructor TStreamReplacer.Create(const aInput: TStream; const aSearch: TStringDynArray);
begin
  inherited Create;
  FInput := aInput;
  FSought := aSearch;
end;

procedure TStreamReplacer.Search;
begin
  BuildTables;
  SearchSought;
end;

procedure TStreamReplacer.Write(const aOutput: TStream; const aReplacer: TReplacer);
begin
  if
    FFound <> nil
  then
    WriteI(aOutput, aReplacer)
  else
    {ERROR};
end;

destructor TStreamReplacer.Destroy;
begin
  ReleaseDynamicStructures;
  inherited Destroy;
end;

end.
