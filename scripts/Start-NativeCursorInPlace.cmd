@echo off
setlocal
set "MAGPIE_NATIVE_SYSTEM_CURSOR=1"
set "MAGPIE_NATIVE_CURSOR_IN_PLACE=1"
start "" "%~dp0Magpie.exe"
