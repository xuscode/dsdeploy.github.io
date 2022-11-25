
REM cd /d C:Program Files (x86)Mozilla Firefox
REM start firefox.exe http://127.0.0.1:8000/

REM cd /d "C:\Program Files\Google\Chrome\Application"
REM start chrome.exe http://127.0.0.1:8000/

cd /d C:\Program Files (x86)\Microsoft\Edge\Application
start msedge.exe http://127.0.0.1:8000/


cd /d %~dp0\
mkdocs build
mkdocs serve

pause

