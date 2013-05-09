var
  first, second: Int64;
begin
  first := aFirst.Value.StreamPosition;
  second := aSecond.Value.StreamPosition;
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
