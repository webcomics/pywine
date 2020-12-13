#!/bin/sh
# Prepare environment:
# - Set Windows version to 10
# - Disable menu updates
# - Disable Mono
# - Disable Gecko
set -e

umask 0
export WINEDLLOVERRIDES="winemenubuilder.exe,mscoree,mshtml="
wine reg add 'HKLM\Software\Microsoft\Windows NT\CurrentVersion' /v CurrentVersion /d 10.0 /f
wine reg add 'HKCU\Software\Wine\DllOverrides' /v winemenubuilder.exe /t REG_SZ /d '' /f
wine reg add 'HKCU\Software\Wine\DllOverrides' /v mscoree /t REG_SZ /d '' /f
wine reg add 'HKCU\Software\Wine\DllOverrides' /v mshtml /t REG_SZ /d '' /f
wineserver -w

