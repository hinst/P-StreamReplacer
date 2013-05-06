unit FileTemplater;

interface

uses
  Types,
  SysUtils,
  Classes,

  StringRoutines,
  StreamReplacer;

type
  TTemplateReplacement = class(TComponent)
  public
    What: string;
    function Write(const aOutput: TStream): boolean; virtual;
  end;

type
  TTemplateStringReplacement = class(TTemplateReplacement)
  public
    Text: string;
    function Write(const aOutput: TStream): boolean; override;
  end;

type
  TTemplateFileReplacement = class(TTemplateReplacement)
  public
    FileName: string;
    function Write(const aOutput: TStream): boolean; override;
  end;

type

  { TFileTemplater }

  TFileTemplater = class(TComponent)
  protected
    FReplacers: TList;
    FReplacer: TStreamReplacer;
    FFileName: TStringDynArray; // 0 is input, 1 is output
    function CreateReplacersStringDynArray: TStringDynArray;
    procedure ReplacerMethod(const aIndex: integer; const aOutput: TStream);
  public
    property FileName: TStringDynArray read FFileName;
    constructor Create(aOwner: TComponent); override;
    procedure AddReplacer(const aReplacer: TTemplateReplacement);
    procedure AddStringReplacer(const aWhat, aWith: string);
    procedure AddFileReplacer(const aWhat, aFileName: string);
    procedure Run;
    destructor Destroy; override;
  end;

implementation

function TTemplateReplacement.Write(const aOutput: TStream): boolean;
var
  n, r: integer;
begin
  n := GetByteLength(What) - 1;
  r := aOutput.Write(PChar(What)^, n);
  Result := n = r;
end;

function TTemplateStringReplacement.Write(const aOutput: TStream): boolean;
var
  n, r: integer;
begin
  n := GetByteLength(Text) - 1;
  r := aOutput.Write(PChar(Text)^, n);
  Result := n = r;
end;

function TTemplateFileReplacement.Write(const aOutput: TStream): boolean;
var
  stream: TFileStream;
  n, r: int64;
begin
  Result := FileName <> '';
  if Result then
  begin
    stream := TFileStream.Create(FileName, fmOpenRead);
    n := stream.Size;
    r := aOutput.CopyFrom(stream, n);
    Result := n = r;
    stream.Free;
  end;
end;

{ TFileTemplater }

function TFileTemplater.CreateReplacersStringDynArray: TStringDynArray;
var
  i: integer;
begin
  if FReplacers <> nil then
  begin
    SetLength(Result, FReplacers.Count);
    for i := 0 to Length(Result) - 1 do
      Result[i] := TTemplateReplacement(FReplacers[i]).What;
  end
  else
    Result := nil;
end;

procedure TFileTemplater.ReplacerMethod(const aIndex: integer; const aOutput: TStream);
var
  replacer: TTemplateReplacement;
  result: boolean;
begin
  replacer := TTemplateReplacement(FReplacers[aIndex]);
  result := replacer.Write(aOutput);
end;

constructor TFileTemplater.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FReplacers := TList.Create;
  SetLength(FFileName, 2);
end;

procedure TFileTemplater.AddReplacer(const aReplacer: TTemplateReplacement);
begin
  FReplacers.Add(aReplacer);
end;

procedure TFileTemplater.AddStringReplacer(const aWhat, aWith: string);
var
  replacer: TTemplateStringReplacement;
begin
  replacer := TTemplateStringReplacement.Create(self);
  replacer.What := aWhat;
  replacer.Text := aWith;
  AddReplacer(replacer);
end;

procedure TFileTemplater.AddFileReplacer(const aWhat, aFileName: string);
var
  replacer: TTemplateFileReplacement;
begin
  replacer := TTemplateFileReplacement.Create(self);
  replacer.What := aWhat;
  replacer.FileName := aFileName;
  AddReplacer(replacer);
end;

procedure TFileTemplater.Run;
var
  inputStream, outputStream: TFileStream;
begin
  inputStream := TFileStream.Create(FileName[0], fmOpenRead);
  outputStream := TFileStream.Create(FileName[1], fmCreate or fmOpenWrite);
  FReplacer := TStreamReplacer.Create(inputStream, CreateReplacersStringDynArray);
  FReplacer.Search;
  FReplacer.Write(outputStream, ReplacerMethod);
  FReplacer.Free;
  outputStream.Free;
  inputStream.Free;
end;

destructor TFileTemplater.Destroy;
begin
  SetLength(FFileName, 0);
  FReplacers.Free;
  inherited Destroy;
end;

end.











