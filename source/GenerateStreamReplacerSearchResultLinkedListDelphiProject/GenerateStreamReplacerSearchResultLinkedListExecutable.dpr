// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
program GenerateStreamReplacerSearchResultLinkedListExecutable;

{$AppType Console}

uses
  SysUtils,
  FileRoutines,
  FileTemplater;

{$Include ..\GenerateStreamReplacerSearchResultLinkedList.inc}

begin
  GenerateStreamReplacerSearchResultLinkedList;
end.
