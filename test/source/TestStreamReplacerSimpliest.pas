program TestStreamReplacerSimpliest;

uses
  Types,
  SysUtils,
  Classes,

  FileRoutines,
  StreamReplacer;

type

  { TReplacer }

  TReplacer = class
  public
    procedure Replace(const aIndex: Integer; const aOutput: TStream);
  end;

var
  inputFile, outputFile: TFileStream;
  inputFileName, outputFileName: string;
  search: TStringDynArray;
  replacer: TStreamReplacer;
  r: TReplacer;

{ TReplacer }

procedure TReplacer.Replace(const aIndex: Integer; const aOutput: TStream);
begin
  Write(aOutput, 'SAMPLE');
end;

begin
  inputFileName := ParamStr(1);
  outputFileName := ParamStr(2);
  inputFile := TFileStream.Create(inputFileName, fmOpenRead);
  outputFile := TFileStream.Create(outputFileName, fmOpenWrite or fmCreate);
  SetLength(search, 1);
  search[0] := '_s';
  replacer := TStreamReplacer.Create(inputFile, search);
  replacer.Search;
  r := TReplacer.Create;
  replacer.Write(outputFile, r.Replace);
  r.Free;
  replacer.Free;
  outputFile.Free;
  inputFile.Free;
end.

















