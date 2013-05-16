program TestStreamStringMultiTemplater;

uses
  Types,
  Classes,
  SysUtils,

  StringRoutines,
  FileRoutines,
  StreamStringMultiTemplater;

var
  o: TFileStream;
  s: TStringStream;
  t: TStreamStringMultiTemplater;

begin
  o := TFileStream.Create('SampleOutputSSMT.txt', fmOpenWrite or fmCreate);
  s := TStringStream.Create('<tr><td>_A</td><td>_B</td></tr>');
  t := TStreamStringMultiTemplater.Create(s, CreateStringDynArray(['_A', '_B']));
  t.Search;
  t.Replacements := CreateStringDynArray(['1!1', '2!2']);
  t.Write(o);
  Write(o, sLineBreak);
  t.Replacements := CreateStringDynArray(['5!56', '6!67']);
  t.Write(o);
  t.Free;
  s.Free;
  o.Free;
end.

