unit FileTemplater;

interface

uses
  Types,
	Classes,
	
	StringRoutines,
	StreamReplacer;

type
	TTemplateReplacement = class(TComponent)
	public
		What: String;
		function Write(const aOutput: TStream): Boolean; virtual;
	end;
	
type
	TTemplateStringReplacement = class(TTemplateReplacement)
	public
		Text: String;
		function Write(const aOutput: TStream): Boolean; override;
	end;
	
type
	TTemplateFileReplacement = class(TTemplateReplacement)
	public
		FileName: String;
		function Write(const aOutput: TStream): Boolean; override;
	end;

type

{ TFileTemplater }

 TFileTemplater = class(TComponent)
	protected
		FReplacers: TList;
    FReplacer: TStreamReplacer;
    FFileName: TStringDynArray; // 0 is input, 1 is output
    function CreateReplacersStringDynArray: TStringDynArray;
    procedure ReplacerMethod(const aIndex: Integer; const aOutput: TStream);
	public
    property FileName: TStringDynArray read FFileName;
		constructor Create(aOwner: TComponent); override;
		procedure AddReplacer(const aReplacer: TTemplateReplacement);
    procedure AddStringReplacer(const aWhat, aWith: String);
    procedure AddFileReplacer(const aWhat, aFileName: String);
    procedure Run;
    destructor Destroy; override;
	end;

implementation

function TTemplateReplacement.Write(const aOutput: TStream): Boolean;
var
  n, r: Integer;
begin
  n := GetByteLength(What);
  r := aOutput.Write(PChar(What)^, n);
  result := n = r;
end;

function TTemplateStringReplacement.Write(const aOutput: TStream): Boolean;
var
  n, r: Integer;
begin
  n := GetByteLength(Text);
	r := aOutput.Write(PChar(Text)^, n);
  result := n = r;
end;

function TTemplateFileReplacement.Write(const aOutput: TStream): Boolean;
var
  stream: TFileStream;
  n, r: Int64;
begin
  result := FileName <> '';
  if
    result
  then
  begin
    stream := TFileStream.Create(FileName, fmOpenRead);
    n := stream.Size;
    r := aOutput.CopyFrom(stream, n);
    result := n = r;
    stream.Free;
  end;
end;

{ TFileTemplater }

function TFileTemplater.CreateReplacersStringDynArray: TStringDynArray;
var
  i: Integer;
begin
  if
    FReplacers <> nil
  then
  begin
    SetLength(result, FReplacers.Count);
    for i := 0 to Length(result) - 1 do
      result[i] := FReplacers[i];
  end
  else
    result := nil;
end;

procedure TFileTemplater.ReplacerMethod(const aIndex: Integer; const aOutput: TStream);
var
  replacer: TTemplateReplacement;
  result: Boolean;
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

procedure TFileTemplater.AddStringReplacer(const aWhat, aWith: String);
var
  replacer: TTemplateStringReplacement;
begin
  replacer := TTemplateStringReplacement.Create(self);
  replacer.What := aWhat;
  replacer.Text := aWith;
  AddReplacer(replacer);
end;

procedure TFileTemplater.AddFileReplacer(const aWhat, aFileName: String);
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
  inputStream := TFileStream.Create(FileName[0]);
  outputStream := TFileStream.Create(FileName[1]);
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






