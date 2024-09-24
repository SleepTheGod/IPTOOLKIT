@echo off
title IPTOOLKIT
mode 75, 30
chcp 65001 >nul
call powershell exit >nul
color A
cd files

:: Main menu loop
:menu
set ip=""
cls
echo.
type "banner.txt"
echo.
echo       PUBLIC IP
echo       ---------
echo     1) Geolocate
echo     2) Trace DNS
echo     3) Port Scan
echo     4) DDOS (Caution: Use Responsibly)
echo.
echo        LOCAL IP
echo       ----------
echo     5) Trace Mac Address
echo     6) Port Scan
echo     7) ARP Spoof (DOS)
echo     8) RPC Dump
echo.
set /p input=Select an option: 
if /I "%input%" EQU "1" goto geolocate
if /I "%input%" EQU "2" goto tracedns
if /I "%input%" EQU "3" goto portscan
if /I "%input%" EQU "4" goto ddos
if /I "%input%" EQU "5" goto Macaddr
if /I "%input%" EQU "6" goto portscan
if /I "%input%" EQU "7" goto arpspoof
if /I "%input%" EQU "8" goto rpcdump
goto menu

:: RPC Dump Function
:rpcdump
cls
echo.
set /p ip=Enter IP Address: 
echo Executing RPC Dump for %ip%...
rpcdump %ip%
echo.
pause
cls
goto menu

:: MAC Address Tracing Function
:Macaddr
cls
echo.
set /p ip=Enter IP Address: 
ping -w 1 %ip% >nul
for /f "tokens=2 delims= " %%a in ('arp -a ^| find "%ip%"') do set macaddr=%%a
if defined macaddr (
    for /f "usebackq delims=" %%I in (`powershell "\"%macaddr%\".toUpper()"`) do set "upper=%%~I"
    echo Mac Address: %upper%
) else (
    echo MAC Address not found for %ip%.
)
echo.
pause
cls
goto menu

:: ARP Spoofing Function
:arpspoof
cls
echo.
set /p ip=Enter IP Address: 
echo Starting ARP Spoofing for %ip%...
start cmd /c "mode 87, 10 && title Spoofing %ip%... && arpspoof.exe %ip%"
goto menu

:: DDOS Function (Disclaimer included)
:ddos
cls
echo WARNING: Use this responsibly!
echo 1) https://freestresser.so/
echo 2) https://hardstresser.com/
echo 3) https://stresser.net/
echo 4) https://str3ssed.co/
echo 5) https://projectdeltastress.com/
echo 6) Back
echo.
set /p ddosinput=Select a service: 
if /I "%ddosinput%" EQU "1" start https://freestresser.so/
if /I "%ddosinput%" EQU "2" start https://hardstresser.com/
if /I "%ddosinput%" EQU "3" start https://stresser.net/
if /I "%ddosinput%" EQU "4" start https://str3ssed.co/
if /I "%ddosinput%" EQU "5" start https://projectdeltastress.com/
if /I "%ddosinput%" EQU "6" goto menu
goto menu

:: Port Scanning Function
:portscan
cls
echo.
set /p ip=Enter IP Address: 
set /p ports=Enter Ports (e.g. 21,22,23): 
echo Scanning ports on %ip%...
start cmd /c "mode 40, 15 && title Scanning Ports... && PortScanner.exe hosts=%ip% ports=%ports% >> portscan.txt"
ping localhost -n 5 >nul
taskkill /im PortScanner.exe /f >nul 2>&1
echo.
type portscan.txt
echo.
del portscan.txt
pause
goto menu

:: DNS Tracing Function
:tracedns
cls
echo.
set /p ip=Enter IP Address: 
for /f "tokens=2 delims= " %%a in ('nslookup %ip% ^| find "Name"') do set dns=%%a
echo.
echo Domain Name: %dns%
echo.
pause
goto menu

:: Geolocation Function
:geolocate
cls
echo.
set /p ip=Enter IP Address: 
echo Looking up geolocation for %ip%...
setlocal ENABLEDELAYEDEXPANSION
set webclient=webclient
if exist "%temp%\%webclient%.vbs" del "%temp%\%webclient%.vbs" /f /q /s >nul
if exist "%temp%\response.txt" del "%temp%\response.txt" /f /q /s >nul

:: Creating the VBS script to fetch geolocation data
echo sUrl = "http://ipinfo.io/%ip%/json" > %temp%\%webclient%.vbs
echo set oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0") >> %temp%\%webclient%.vbs
echo oHTTP.open "GET", sUrl, false >> %temp%\%webclient%.vbs
echo oHTTP.send >> %temp%\%webclient%.vbs
echo strResponse = oHTTP.responseText >> %temp%\%webclient%.vbs
echo set objFSO = CreateObject("Scripting.FileSystemObject") >> %temp%\%webclient%.vbs
echo set objFile = objFSO.CreateTextFile("%temp%\response.txt", True) >> %temp%\%webclient%.vbs
echo objFile.Write(strResponse) >> %temp%\%webclient%.vbs
echo objFile.Close >> %temp%\%webclient%.vbs

start /wait %temp%\%webclient%.vbs

:: Check for response
set /a attempts=0
:checkresponse
set /a attempts+=1
if %attempts% gtr 7 goto failed
if exist "%temp%\response.txt" goto display_response
ping 127.0.0.1 -n 2 >nul
goto checkresponse

:failed
echo.
echo Did not receive a response from the API.
pause
goto menu

:display_response
cls
echo Geolocation Data:
for /f "delims=" %%i in ('findstr /i "," %temp%\response.txt') do (
    echo %%i
)
echo.
del "%temp%\%webclient%.vbs" /f /q /s >nul
del "%temp%\response.txt" /f /q /s >nul
pause
goto menu
