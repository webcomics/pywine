#!/bin/sh
set -e

here="$(cd "$(dirname "$0")"; pwd)"

rm -Rf "$here/pywine"
export WINEPREFIX="$here/pywine"
export WINEARCH=win32
export WINEDLLOVERRIDES="winemenubuilder.exe,mscoree,mshtml="

# Set Windows Version (Windows 7)
#wine reg add 'HKLM\Software\Microsoft\Windows NT\CurrentVersion' /v CurrentVersion /d 6.1

# Disable menu updates
wine reg add 'HKCU\Software\Wine\DllOverrides' /v winemenubuilder.exe /t REG_SZ /d ""
# Disable Mono
wine reg add 'HKCU\Software\Wine\DllOverrides' /v mscoree /t REG_SZ /d ""
# Disable Gecko
wine reg add 'HKCU\Software\Wine\DllOverrides' /v mshtml /t REG_SZ /d ""

# Get Python
mkdir -p "$here/cache"
cd "$here/cache"
wget -c https://www.python.org/ftp/python/3.4.4/python-3.4.4.msi
sha256sum -c "$here/SHA256SUMS.txt"

# Install Python
wine msiexec /i python-3.4.4.msi /q

# Configure Python
PYDIR="$here/pywine/drive_c/Python34"
cp "$here/"*.whl "$PYDIR"
cd "$PYDIR"
wine python -m pip install -v --upgrade pip setuptools
wine python -m pip install -v pbr pyinstaller==3.1.1
wine python -m pip install -v *.whl
rm -v *.whl
wine python -m pip list
cd "$here"

# Delete symlinks leaving the Wine prefix
rm pywine/dosdevices/z:
find pywine/drive_c -type l -delete
tar cvaf pywine.tar.xz pywine

