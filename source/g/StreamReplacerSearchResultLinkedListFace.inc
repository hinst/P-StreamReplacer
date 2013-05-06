type
  PStreamReplacerSearchResultLinkedList = ^TStreamReplacerSearchResultLinkedList;
  TStreamReplacerSearchResultLinkedList = record
    Value: TStreamReplacerSearchResult;
    Next: PStreamReplacerSearchResultLinkedList;
  end;

procedure Append(var aList, aTail: PStreamReplacerSearchResultLinkedList; const aValue: TStreamReplacerSearchResult); overload; inline;

function Next(var aCurrent: PStreamReplacerSearchResultLinkedList; out aValue: TStreamReplacerSearchResult): boolean; overload; inline;

function DisposeList(const aList: PStreamReplacerSearchResultLinkedList): PStreamReplacerSearchResultLinkedList; overload; inline;


