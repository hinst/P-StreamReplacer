program TestStreamReplacer002;

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
  case aIndex of
    0:
  begin
    Write(aOutput, 'SAMPLE');
  end;
    1:
  begin
    Write(aOutput, 'aBCd');
  end;
  end;;
end;

begin
  inputFileName := ParamStr(1);
  outputFileName := ParamStr(2);
  WriteLn(inputFileName, ';', outputFileName);
  inputFile := TFileStream.Create(inputFileName, fmOpenRead);
  outputFile := TFileStream.Create(outputFileName, fmOpenWrite or fmCreate);
  SetLength(search, 2);
  search[0] := '_s';
  search[1] := '_replaceThis';
  replacer := TStreamReplacer.Create(inputFile, search);
  replacer.Search;
  r := TReplacer.Create;
  replacer.Write(outputFile, r.Replace);
  r.Free;
  replacer.Free;
  outputFile.Free;
  inputFile.Free;
end.

















