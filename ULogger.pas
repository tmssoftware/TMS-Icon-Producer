unit ULogger;

interface
uses SysUtils;
type
  TLogChannel = (Main, Resize, Optimize, Count);
  TLogger = TProc<TLogChannel, string>;
 
implementation
end.
