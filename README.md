# Python3-Wine

![License](https://img.shields.io/github/license/webcomics/pywine)
![Maintenance](https://img.shields.io/maintenance/yes/2021)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/tobix/pywine/latest)

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

 * Python 3.7.9
 * PyInstaller
