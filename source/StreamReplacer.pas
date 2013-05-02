unit StreamReplacer;

interface

uses
  Types,
  SysUtils,
  Classes,
  
  LinkedList,
  Int64LinkedList;

type
  TStreamReplacer = class
  protected
    var
      FSought: TStringDynArray;
      FTables: array of TIntegerDynArray;
      FFound: array of PInt64LinkedList;
      FInput: TStream;
    type
      TReplacer = procedure(const aIndex: Integer; const aOutput: TStream) of object;
    procedure WriteI(const aOutput: TStream; const aReplacer: TReplacer);
    procedure BuildTables;
    function SearchThis(const aIndex: Integer): PInt64LinkedList;
    procedure SearchSought;
    function NextFound(const aCurrent: Int64; out aSoughtIndex: Integer): Int64;
    procedure ReleaseDynamicStructures;
  public
    constructor Create(const aInput: TStream; const aSearch: TStringDynArray);
    procedure Search;
    procedure Write(const aOutput: TStream; const aReplacer: TReplacer);
    destructor Destroy; override;
  end;

implementation

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
    //Write(aIndex, ' ');
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
  position: Int64;
  index: Integer;
begin
  FInput.Seek(0, soFromBeginning);
  position := -1;
  position := NextFound(position, index);
  while position <> -1 do
  begin
    WriteLn('Position: ', position, '; index: ', index,
      '; FInput position: ', FInput.Position);
    if
      position <> 0
    then
      aOutput.CopyFrom(FInput, position - FInput.Position);
    WriteLn('FInput position: ', FInput.Position);
    aReplacer(index, aOutput);
    FInput.Seek(Length(FSought[index]), soFromCurrent);
    position := NextFound(position, index);
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

function TStreamReplacer.SearchThis(const aIndex: Integer): PInt64LinkedList;
var
  index: Int64;
  currentSought: string;
  tail: PInt64LinkedList;
begin
  tail := nil;
  index := 0;
  currentSought := FSought[aIndex];
  WriteLn('Now searching: ', currentSought);
  repeat
    index := KMPSearchStream(index, currentSought, FInput, FTables[aIndex]);
    if
      -1 = index
    then
      break;
    WriteLn('Found: ', index);
    Append(result, tail, index);
    Inc(index);
  until False;
end;

procedure TStreamReplacer.SearchSought;
var
  i: Integer;
begin
  SetLength(FFound, Length(FSought));
  for i := 0 to Length(FSought) - 1 do
    FFound[i] := SearchThis(i);
end;

function TStreamReplacer.NextFound(const aCurrent: Int64; out aSoughtIndex: Integer): Int64;
var
  i: Integer;
  x: Int64;
  tail: PInt64LinkedList;
begin
  result := -1;
  for i := 0 to Length(FFound) - 1 do
  begin
    tail := FFound[i];
    while 
      Next(tail, x) 
    do
    begin
      if
        aCurrent < x
      then
        if
          (result = -1)
          or
          (x < result)
        then
        begin
          result := x;
          aSoughtIndex := i;
        end;
    end;
  end;
end;

procedure TStreamReplacer.ReleaseDynamicStructures;
var
  i: Integer;
begin
  SetLength(FSought, 0);
  for i := 0 to Length(FTables) - 1 do
    SetLength(FTables[i], 0);
  SetLength(FTables, 0);
  for i := 0 to Length(FFound) - 1 do
    DisposeList(FFound[i]);
  SetLength(FFound, 0);
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
