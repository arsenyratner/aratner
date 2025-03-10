@echo off
::workdir=%ProgramFiles%\cmdutils
set APG=%ProgramFiles%\cmdutils\apg.exe
set OPTIONS=-n5 -EOI10l -a0 -MNCLs -c cl_seed
set PWLEN=8
"%APG%" %OPTIONS% -m %PWLEN% -x %PWLEN% 
set PWLEN=10
"%APG%" %OPTIONS% -m %PWLEN% -x %PWLEN% 
set PWLEN=15
"%APG%" %OPTIONS% -m %PWLEN% -x %PWLEN%
