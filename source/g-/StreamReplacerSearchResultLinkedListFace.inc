type
  P_LT = ^T_LT;
  T_LT = record
    Value: TStreamReplacerSearchResult;
    Next: P_LT;
  end;

procedure Append(var aList, aTail: P_LT; const aValue: TStreamReplacerSearchResult); overload; inline;

function Next(var aCurrent: P_LT; out aValue: TStreamReplacerSearchResultStreamReplacerSearchResultLinkedListStreamReplacerSearchResultLinkedListStreamReplacerSearchResultLinkedListStreamReplacerSearchResultLinkedListStreamReplacerSearchResultLinkedListStreamReplacerSearchResultLinkedListad; inline;

function DisposeList(const aList: PStreamReplacerSearchResultLinkedList): PStreamReplacerSearchResultLinkedList; overload; inline;


