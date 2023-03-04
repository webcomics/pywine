FROM tobix/wine:stable
MAINTAINER Tobias Gruetzmacher "tobias-docker@23.gs"

ENV WINEDEBUG -all
ENV WINEPREFIX /opt/wineprefix

COPY wine-init.sh SHA256SUMS.txt keys.gpg /tmp/helper/
COPY mkuserwineprefix /opt/

# Prepare environment
RUN xvfb-run sh /tmp/helper/wine-init.sh

# renovate: datasource=github-tags depName=python/cpython versioning=pep440
ARG PYTHON_VERSION=3.7.9
ARG PYINSTALLER_VERSION=5.8.0
ARG UCRT_VERSION=10.0.22621.1
# renovate: datasource=github-releases depName=upx/upx versioning=loose
ARG UPX_VERSION=3.96

RUN umask 0 && cd /tmp/helper && \
  curl -LOOO \
    https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe{,.asc} \
    https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-win64.zip \
    https://github.com/huangqinjin/ucrt/releases/download/10.0.22621.0/ucrt-x64-${UCRT_VERSION}.zip \ 
  && \
  gpgv --keyring ./keys.gpg python-${PYTHON_VERSION}-amd64.exe.asc python-${PYTHON_VERSION}-amd64.exe && \
  sha256sum -c SHA256SUMS.txt && \
  xvfb-run sh -c "\
    wine python-${PYTHON_VERSION}-amd64.exe /quiet TargetDir=C:\\Python \
      Include_doc=0 InstallAllUsers=1 PrependPath=1; \
    wineserver -w" && \
  unzip upx*.zip && \
  mv -v upx*/upx.exe ${WINEPREFIX}/drive_c/windows/ && \
  unzip ucrt*.zip && \
  mv ucrt*/* ${WINEPREFIX}/drive_c/Python &&\
  cd .. && rm -Rf helper

# Install some python software
RUN umask 0 && xvfb-run sh -c "\
  wine pip install --no-warn-script-location "pyinstaller==${PYINSTALLER_VERSION}"; \
  wineserver -w"

