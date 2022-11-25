REM @echo off
REM set date=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
REM echo %data%

REM cd /d %~dp0
REM mkdocs build

REM copy CNAME site\
REM cd /d %~dp0\site
REM git status

REM git add .

REM @echo WRITE UPDATE AND PRESS ENTER:
REM ::set /p GetYourLog=
REM git commit -m "%date%"
REM git push --force

REM cd ..

REM timeout /t 10



cd /d %~dp0

mkdocs gh-deploy