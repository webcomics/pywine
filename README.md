# Python3 in Wine in Docker

![License](https://img.shields.io/github/license/webcomics/pywine)
![Maintenance](https://img.shields.io/maintenance/yes/2025)
![Docker Image Size](https://img.shields.io/docker/image-size/tobix/pywine/latest)

This is a docker container to help building Python applications in Wine. It
installs Python and PyInstaller to be able to build "native" Windows
applications. It also installs UPX, so PyInstaller can use it to compress
binaries.

Since Python 3.9, this uses the 64-bit version of Python, since that is the
default download from python.org. If you need a different version, please use
one of the tags described [below](#older-python-versions).

This dockerfile does some umask trickery to create a wineprefix usable by any
user. This makes it convinient to use from a Jenkins build, since those often
use a non-root user inside the container. Unfortunatly, wine doesn't like to
use a wineprefix not owned by the current user. If you want to use the "global"
wineprefix from another user, you can source the `/opt/mkuserwineprefix` script
to create an "usable" wineprefix:

```sh
  . /opt/mkuserwineprefix
```

## Older Python versions

If you need older Python versions for some reason, there are currently tags for
the following Python branches:

 * Python 3.13.x: `tobix/pywine:3.13`
 * Python 3.12.x: `tobix/pywine:3.12`
 * Python 3.11.x: `tobix/pywine:3.11`
 * Python 3.10.x: `tobix/pywine:3.10`

Older branches might be out-of-date. Please create an
[issue](https://github.com/webcomics/pywine/issues/new/choose) if you need any
updates.
