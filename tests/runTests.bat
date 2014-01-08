:: Compiles and runs the tests on neko target.
:: Deletes bin dir at the end.
:: Loops until no longer desired.
:: Can be used with other targets if needed.
set TARGET=neko
@echo off
:yes
cls
call lime test compile.xml %TARGET%
rmdir bin /s /q

SET /P ANSWER=Run tests again? (Y/N)?
if /i {%ANSWER%}=={y} (goto :yes)
if /i {%ANSWER%}=={yes} (goto :yes)
exit /b 1 





