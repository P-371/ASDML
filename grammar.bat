: '"
@echo off
echo.
goto CMDSCRIPT
"'
: ########
: # bash #
: ########
shopt -s extglob
echo
cd Grammar

case $1 in
  clean)
    rm -v !(*.g4)
    rm -rf .antlr
    ;;
  generate)
    if [ $# -lt 2 ]
    then
        echo No language specified, exiting.
        exit 1
    fi
    LANG=$2
    shift 2
    antlr4 ASDML.g4 -Dlanguage=$LANG $*
    ;;
  test)
    shift
    antlr4 ASDML.g4
    javac ASDML*.java
    echo Enter test input:
    grun ASDML asdml $*
    ;;
  *)
    echo Usage:
    echo -e "  $0 clean"
    echo -e "  $0 generate <language> [options]"
    echo -e "  $0 test [options]"
    ;;
esac
cd ..
exit 0

: #######
: # cmd #
: #######
:CMDSCRIPT
cd Grammar
IF "%1"=="clean" GOTO CLEAN
IF "%1"=="generate" GOTO GENERATE
IF "%1"=="test" GOTO TEST
GOTO :END

:CLEAN
  for %%i in (*) do if not "%~xi" == ".g4" del /Q "%%i"
  rmdir /S /Q .antlr
  GOTO END
:GENERATE
  IF "%2"=="" echo No language specified, exiting.
  IF "%2"=="" cd ..
  IF "%2"=="" exit /b 1

  set LANG=%2
  shift
  shift

  set ARGS=%1
  :loop
  shift
  if "%1"=="" goto break
  set ARGS=%ARGS% %1
  goto loop
  :break

  antlr4 ASDML.g4 -Dlanguage=%LANG% %ARGS%
  GOTO END
:TEST
  antlr4 ASDML.g4
  javac ASDML*.java
  echo Enter test input:
  grun ASDML asdml $*
  GOTO END

:END
cd ..
exit /b 0
