function Create(const aValue: TStreamReplacerSearchResult): PStreamReplacerSearchResultLinkedList; inline;
begin
  New(result);
  result.Value := aValue;
  result.Next := nil;
end;

procedure Append(var aList, aTail: PStreamReplacerSearchResultLinkedList; const aValue: TStreamReplacerSearchResult);
var
  item: PStreamReplacerSearchResultLinkedList;
begin
  item := Create(aValue);
	if
		aTail <> nil
	then
		aTail.Next := item
	else
		aList := item;
	aTail := item;
end;

function Next(var aCurrent: PStreamReplacerSearchResultLinkedList; out aValue: TStreamReplacerSearchResult): boolean;
begin
	result := aCurrent <> nil;
	if
		result
	then
	begin
		aValue := aCurrent.Value;
		aCurrent := aCurrent.Next;
	end;
end;

function DisposeList(const aList: PStreamReplacerSearchResultLinkedList): PStreamReplacerSearchResultLinkedList;
var
  item: PStreamReplacerSearchResultLinkedList;
begin
  result := aList;
  while
    result <> nil
  do
  begin
    item := result;
    result := result.Next;
    Dispose(item);
  end;
end;


