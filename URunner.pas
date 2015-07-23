unit URunner;

interface
uses ULogger, Windows, SysUtils;

procedure Run(const Feedback: TLogger; const LogChannel: TLogChannel;
         const FileName, CurrDir: string; const Parameters: string;
         const ExpectedExit: integer = 0);

implementation
uses ShellAPI;

procedure Run(const Feedback: TLogger; const LogChannel: TLogChannel; const FileName, CurrDir: string; const Parameters: string;
              const ExpectedExit: integer = 0);
const
   ReadBuffer = 2400;
var
  Security : TSecurityAttributes;
  ReadPipe,WritePipe : THandle;
  start : TStartUpInfo;
  ProcessInfo : TProcessInformation;
  Buffer : TBytes;
  BytesRead : DWord;
  Apprunning : DWord;
  ExitCode: DWORD;
  CommandLine : string;
  Avail: DWord;
  PCurrDir: PWideChar;
  LocalText: string;
  PCommandLine: PChar;
  PEnvironment: PChar;
begin
   PEnvironment :=nil;
   if CurrDir = '' then PCurrDir := nil else PCurrDir := PWideChar(CurrDir);

   SetLength(Buffer, ReadBuffer + 1);
   LocalText := '';
   ZeroMemory(@Security, SizeOf(TSecurityAttributes));
   ZeroMemory(@ProcessInfo, SizeOf(TProcessInformation));
   Security.nlength := SizeOf(TSecurityAttributes) ;
   Security.binherithandle := true;
   Security.lpsecuritydescriptor := nil;

   if not Createpipe (ReadPipe, WritePipe, @Security, 0) then raise Exception.Create('Error running ' +  FileName);
   try
     FillChar(Start,Sizeof(Start),#0) ;
     start.cb := SizeOf(start) ;
     start.hStdOutput := WritePipe;
     start.hStdError := WritePipe;
     start.hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdinput;
     start.dwFlags := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
     start.wShowWindow := SW_HIDE;

     CommandLine := '"' + FileName + '" ' + Parameters;
     PCommandLine := PChar(CommandLine);
     if not CreateProcess(nil,
           PCommandLine,
           @Security,
           @Security,
           true,
           NORMAL_PRIORITY_CLASS or CREATE_UNICODE_ENVIRONMENT,
           PEnvironment,
           PCurrDir,
           start,
           ProcessInfo)
    then raise Exception.Create('Error running ' +  FileName);

    try
      Repeat
        Apprunning := WaitForSingleObject(ProcessInfo.hProcess,100) ;
        Repeat
          PeekNamedPipe(ReadPipe, nil, 0, nil, @Avail, nil);
          if Avail > 0 then
          begin
            BytesRead := 0;
            ReadFile(ReadPipe, Buffer[0], ReadBuffer, BytesRead, nil) ;
            LocalText := LocalText + TEncoding.ASCII.GetString(Buffer, 0, BytesRead);
          end;
        until (Avail = 0) ;

        if Assigned(Feedback) then Feedback(LogChannel, LocalText);
        LocalText:='';

      until (Apprunning <> WAIT_TIMEOUT) ;

      GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
      if (integer(ExitCode) <> ExpectedExit) then raise Exception.Create('Error running: ' +FileName + '  Exit code: ' + IntToStr(ExitCode));

    finally
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
    end;
  finally
    CloseHandle(ReadPipe);
    CloseHandle(WritePipe);
  end;
end;
end.
