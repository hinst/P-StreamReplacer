unit StreamStringMultiTemplater;

interface

uses
  Types,
  Classes,

  FileRoutines,
  StreamReplacer;

type

  { TStreamStringMultiTemplater }

  TStreamStringMultiTemplater = class(TStreamReplacer)
  protected
    procedure Replace(const aIndex: Integer; const aOutput: TStream); overload;
  public
    Replacements: TStringDynArray;
    procedure Write(const aOutput: TStream); overload;
  end;

implementation

{ TStreamStringMultiTemplater }

procedure TStreamStringMultiTemplater.Replace(const aIndex: Integer;
  const aOutput: TStream);
begin
  FileRoutines.Write(aOutput, Replacements[aIndex]);
end;

procedure TStreamStringMultiTemplater.Write(const aOutput: TStream);
begin
  inherited Write(aOutput, self.Replace);
end;

end.

