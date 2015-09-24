@echo off
call lime test flash -debug 
pause
call lime test neko -debug -Dlegacy
pause
call lime test cpp -debug -Dlegacy
pause
call haxelib run flow run web
pause
call haxelib run flow run windows