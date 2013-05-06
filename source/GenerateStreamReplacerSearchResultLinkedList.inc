procedure GenerateStreamReplacerSearchResultLinkedList;
var
  templater: TFileTemplater;
begin
  templater := TFileTemplater.Create(nil);
  templater.AddStringReplacer('_T', 'TStreamReplacerSearchResult');
  templater.AddStringReplacer('_LT', 'StreamReplacerSearchResultLinkedList');
  templater.FileName[0] := '..' + ;
  templater.FileName[1] := '';
  templater.Run;
  templater.Free;
end;

