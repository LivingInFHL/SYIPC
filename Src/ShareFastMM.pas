unit ShareFastMM;

interface

uses
  Windows;

implementation

var
  FastMMHexTable: array[0..15] of AnsiChar = ('0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
  FastMMMappingObjectName: array[0..25] of AnsiChar = ('L', 'o', 'c', 'a', 'l', '\',
    'F', 'a', 's', 't', 'M', 'M', '_', 'P', 'I', 'D', '_', '?', '?', '?', '?',
    '?', '?', '?', '?', #0);

{$IF CompilerVersion < 18}
type
  PMemoryManagerEx = ^TMemoryManagerEx;
  TMemoryManagerEx = record
    GetMem: function(Size: Integer): Pointer;
    FreeMem: function(P: Pointer): Integer;
    ReallocMem: function(P: Pointer; Size: Integer): Pointer;
    AllocMem: function(Size: Cardinal): Pointer;
    RegisterExpectedMemoryLeak: function(P: Pointer): Boolean;
    UnregisterExpectedMemoryLeak: function(P: Pointer): Boolean;
  end;
  function RegisterExpectedMemoryLeak(P: Pointer): Boolean;
  begin
    Result := False;
  end;

  function UnregisterExpectedMemoryLeak(P: Pointer): Boolean;
  begin
    Result := False;
  end;
{$IFEND}
  
var
  OldMemoryManager: TMemoryManagerEx;
  NewMemoryManager: TMemoryManagerEx;
  MemoryManagerIsInstalled: Boolean = False;
procedure ZeroMemory(Destination: Pointer; Length: DWORD);
begin
  FillChar(Destination^, Length, 0);
end;

procedure InstallMemoryManager;
var
  i, LCurrentProcessID: Cardinal;
  LPMapAddress: PPointer;
  LChar: AnsiChar;
  MappingObjectHandle: Cardinal;
begin
  {$WARN SYMBOL_DEPRECATED OFF}
  if MemoryManagerIsInstalled or IsMemoryManagerSet or (AllocMemSize <> 0) then
    Exit;
  {$WARN SYMBOL_DEPRECATED ON}

  {$IF CompilerVersion < 18}
    ZeroMemory(@OldMemoryManager, SizeOf(TMemoryManagerEx));
    ZeroMemory(@NewMemoryManager, SizeOf(TMemoryManagerEx));
    GetMemoryManager(PMemoryManager(@OldMemoryManager)^);
  {$ELSE}
    GetMemoryManager(OldMemoryManager);
  {$IFEND}

  if IsLibrary then
  begin //��װFastMM
    LCurrentProcessID := GetCurrentProcessId;
    for i := 0 to 7 do
    begin
      LChar := FastMMHexTable[((LCurrentProcessID shr (i * 4)) and $F)];
      FastMMMappingObjectName[(High(FastMMMappingObjectName) - 1) - i] := LChar;
    end;
    MappingObjectHandle := OpenFileMappingA(FILE_MAP_READ, False, FastMMMappingObjectName);
    if MappingObjectHandle = 0 then
      Exit;
    try
      LPMapAddress := MapViewOfFile(MappingObjectHandle, FILE_MAP_READ, 0, 0, 0);
      NewMemoryManager := PMemoryManagerEx(LPMapAddress^)^;
      UnmapViewOfFile(LPMapAddress);
    finally
      CloseHandle(MappingObjectHandle);
    end;
  end;

{$IF CompilerVersion < 18}
  SetMemoryManager(System.PMemoryManager(@NewMemoryManager)^);
{$ELSE}
  SetMemoryManager(NewMemoryManager);
{$IFEND}
  MemoryManagerIsInstalled := True;
end;

procedure UninstallMemoryManager;
begin
  if MemoryManagerIsInstalled then
  begin
  {$IF CompilerVersion < 18}
    SetMemoryManager(System.PMemoryManager(@OldMemoryManager)^);
  {$ELSE}
    SetMemoryManager(OldMemoryManager);
  {$IFEND}
    MemoryManagerIsInstalled := False;
  end;
end;

initialization
  InstallMemoryManager;

finalization
  UninstallMemoryManager;
  
end.
