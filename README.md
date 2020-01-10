# Python3-Wine

![license](https://img.shields.io/github/license/webcomics/pywine.svg)
![Maintenance](https://img.shields.io/maintenance/yes/2020.svg)
![Docker Automated build](https://img.shields.io/docker/automated/tobix/pywine.svg)
[![](https://images.microbadger.com/badges/image/tobix/pywine.svg)](https://microbadger.com/images/tobix/pywine "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/tobix/pywine.svg)](https://microbadger.com/images/tobix/pywine "Get your own commit badge on microbadger.com")

This is a docker container to help building Python applications in Wine. It
installs Python, PyInstaller and some extensions to be able to build "native"
Windows applications. It also installs UPX, so PyInstaller can use it to
compress binaries.

This dockerfile does some umask trickery to create a wineprefix usable by any
user. This makes is convinient to use from a Jenkins build, since those often
use a non-root user inside the container. Unfortunatly, wine doesn't like to
use a wineprefix not owned by the current user. If you want to use the "global"
wineprefix from another user, you can source the `/opt/mkuserwineprefix` script
to create an "usable" wineprefix:

```sh
  . /opt/mkuserwineprefix
```

This is currently installed:

 * Python 3.7.6
 * pbr
 * PyInstaller
