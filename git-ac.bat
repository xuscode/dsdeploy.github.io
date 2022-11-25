set date=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
echo %data%

@echo off

cd /d %~dp0

git add *.md

@echo WRITE UPDATE AND PRESS ENTER:
::set /p GetYourLog=
git commit -m "%date%"
git push


pause