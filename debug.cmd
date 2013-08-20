@ECHO OFF
REM --------------------------------------------------------------------
REM Debug.cmd v 1.0.1

REM --------------------------------------------------------------------
SET PROJECT_BIN=%CD%\bin
SET FILENAME=main
REM --------------------------------------------------------------------

REM --------------------------------------------------------------------
SET DBGPATH=\programs\development\rce\debuggers\ollydbg
SET CHECK_DRIVES=C Y Z

FOR %%i IN (%CHECK_DRIVES%) DO (
	IF EXIST %%i:%DBGPATH%. SET DBGPATH=%%i:%DBGPATH%
)
SET DBGEXE=%DBGPATH%\asphx.exe

IF NOT EXIST %DBGEXE%. (
    ECHO NO DEBUGGER FOUND! CHECK PATH IN DEBUG.CMD
    ECHO DBG=%DBGEXE%
    GOTO ERROR
)
REM --------------------------------------------------------------------

IF EXIST %PROJECT_BIN%\%FILENAME%.exe. (
	START /D"%DBGPATH%" "" "%DBGEXE%" "%PROJECT_BIN%\%FILENAME%.exe"
	GOTO FINISH
)

SET /P CHOISE=Compile it first. Launch make.cmd? (y/n)
IF %CHOISE%==y (
	START /D"%CD%" make.cmd
	GOTO FINISH
)
:ERROR
    PAUSE>nul

:FINISH
    EXIT
REM --------------------------------------------------------------------