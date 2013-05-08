procedure GenerateStreamReplacerSearchResultLinkedList;
var
  templater: TFileTemplater;
begin
  WriteLn('Now generating list from template...');
  templater := TFileTemplater.Create(nil);
  templater.AddStringReplacer('_T', 'TStreamReplacerSearchResult');
  templater.AddStringReplacer('_LT', 'StreamReplacerSearchResultLinkedList');
  templater.FileName[0] :=
    Path(['..', '..', 'P-Containers', 'source', 'LinkedListTemplateFace.inc']);
  templater.FileName[1] := Path(['g-', 'StreamReplacerSearchResultLinkedListFace.inc']);
  templater.Run;
  WriteLn(templater.LatestResultAsDebugText);
  templater.FileName[0] :=
    Path(['..', '..', 'P-Containers', 'source', 'LinkedListTemplateImpl.inc']);
  templater.FileName[1] := Path(['g-', 'StreamReplacerSearchResultLinkedListImpl.inc']);
  templater.Run;
  WriteLn(templater.LatestResultAsDebugText);
  templater.Free;

  WriteLn('Now generating sorting routine from template...');
  templater := TFileTemplater.Create(nil);
  templater.AddStringReplacer('_SortFunction', 'SortSearchResults');
  templater.AddStringReplacer('_PT', 'PStreamReplacerSearchResultLinkedList');
  templater.AddFileReplacer(
    '_CompareFunctionBody',
    'SortStreamReplacerSearchResultLinkedListRoutineBody.inc'
  );
  templater.AddStringReplacer('_Next', 'Next');
  templater.FileName[0] :=
    Path(['..', '..', 'P-SortLinkedList', 'source', 'SortLinkedListTemplateImplementation.inc']);
  templater.FileName[1] :=
    Path(['g-', 'SortStreamReplacerSearchResultLinkedListImplementation.inc']);
  templater.Run;
  WriteLn(templater.LatestResultAsDebugText);
  templater.Free;
end;

