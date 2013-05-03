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
	public
		constructor Create(aOwner: TComponent); override;
		procedure AddReplacer(const aReplacer: TTemplateReplacement);
    destructor Destroy; override;
	end;

implementation

function TTemplateReplacement.Write(const aOutput: TStream): Boolean;
begin
  aOutput.Write(PChar(What)^, GetByteLength(What));
end;

function TTemplateStringReplacement.Write(const aOutput: TStream): Boolean;
begin
	aOutput.Write(PChar(Text)^, GetByteLength(Text));
end;

function TTemplateFileReplacement.Write(const aOutput: TStream): Boolean;
var
  stream: TFileStream;
begin
  result := FileName <> '';
  if
    result
  then
  begin
    stream := TFileStream.Create(FileName, fmOpenRead);
    aOutput.CopyFrom(stream, stream.Size);
    stream.Free;
  end;
end;

{ TFileTemplater }

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

destructor TFileTemplater.Destroy;
begin
  SetLength(FFileName, 0);
  FReplacers.Free;
  inherited Destroy;
end;

end.






