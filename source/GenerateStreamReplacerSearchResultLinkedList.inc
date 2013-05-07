procedure GenerateStreamReplacerSearchResultLinkedList;
var
  templater: TFileTemplater;
begin
  templater := TFileTemplater.Create(nil);
  templater.AddStringReplacer('_T', 'TStreamReplacerSearchResult');
  templater.AddStringReplacer('_LT', 'StreamReplacerSearchResultLinkedList');
  templater.FileName[0] :=
    Path(['..', '..', 'P-Containers', 'source', 'LinkedListTemplateFace.inc']);
  templater.FileName[1] := Path(['g', 'StreamReplacerSearchResultLinkedListFace.inc']);
  templater.Run;
  WriteLn(templater.LatestResultAsDebugText);
  templater.FileName[0] :=
    Path(['..', '..', 'P-Containers', 'source', 'LinkedListTemplateImpl.inc']);
  templater.FileName[1] := Path(['g', 'StreamReplacerSearchResultLinkedListImpl.inc']);
  templater.Run;
  WriteLn(templater.LatestResultAsDebugText);
  templater.Free;
end;

