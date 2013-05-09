function SortSearchResultsCompare(const aFirst, aSecond: PStreamReplacerSearchResultLinkedList): Integer; inline;
var
  first, second: Int64;
begin
  first := aFirst.Value.StreamPosition;
  second := aFirst.Value.StreamPosition;
  if
    first < second
  then
    result := -1
  else
    if first = second then
      result := 0
    else
      result := 1;
end;


function SortSearchResults(list: PStreamReplacerSearchResultLinkedList): PStreamReplacerSearchResultLinkedList;
var
	p, q, e, tail, oldhead: PStreamReplacerSearchResultLinkedList;
	insize, nmerges, psize, qsize, i: Integer;
begin
	if 
		nil = list
	then
		result := nil
	else
	begin
		insize := 1;
		while
			True
		do
		begin
			p := list;
			oldhead := list;
			list := nil;
			tail := nil;
			nmerges := 0;
			while 
				p <> nil
			do
			begin
				Inc(nmerges);
				q := p;
				psize := 0;
				for i := 0 to insize - 1 do
				begin
					Inc(psize);
					q := q.Next;
					if 
						q = nil
					then
						break;
				end;
				qsize := insize;
				while 
					(psize > 0)
					or
					(
						(qsize > 0)
						and
						(q <> nil)
					)
				do
				begin
					if 
						0 = psize
					then
					begin
						e := q;
						q := q.Next;
						Dec(qsize);
					end
					else if
						(0 = qsize) or (nil = q)
					then
					begin
						e := p;
						p := p.Next;
						Dec(psize);
					end
					else if
						SortSearchResultsCompare(p, q) <= 0
					then
					begin
						e := p;
						p := p.Next;
						Dec(psize);
					end
					else
					begin
						e := q;
						q := q.Next;
						Dec(qsize);
					end;
					if 
						tail <> nil
					then
						tail.Next := e
					else
						list := e;
					tail := e;
				end;
				p := q;
			end;
			tail.Next := nil;
			if 
				nmerges  <= 1
			then
			begin
				result := list;
				break;
			end
			else
				insize := 2 * insize;
		end;
	end;
end;
